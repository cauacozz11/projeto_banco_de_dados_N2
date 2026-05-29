CREATE OR REPLACE FUNCTION public.handle_novo_usuario()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (user_id, nome_completo, papel)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'nome_completo', 'Sem nome'),
        COALESCE(NEW.raw_user_meta_data->>'papel', 'aluno')
    );
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER ao_criar_usuario
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_novo_usuario();

CREATE OR REPLACE FUNCTION public.atualizar_contadores_sessao()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.sessoes_simulado
    SET
        total_questoes = total_questoes + 1,
        total_acertos  = total_acertos + (CASE WHEN NEW.acertou THEN 1 ELSE 0 END)
    WHERE id = NEW.sessao_id;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER ao_inserir_resposta
    AFTER INSERT ON public.respostas
    FOR EACH ROW
    EXECUTE FUNCTION public.atualizar_contadores_sessao();

CREATE OR REPLACE FUNCTION public.decrementar_contadores_sessao()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.sessoes_simulado
    SET
        total_questoes = GREATEST(total_questoes - 1, 0),
        total_acertos  = GREATEST(total_acertos - (CASE WHEN OLD.acertou THEN 1 ELSE 0 END), 0)
    WHERE id = OLD.sessao_id;
    RETURN OLD;
END;
$$;

CREATE OR REPLACE TRIGGER ao_deletar_resposta
    AFTER DELETE ON public.respostas
    FOR EACH ROW
    EXECUTE FUNCTION public.decrementar_contadores_sessao();

CREATE OR REPLACE FUNCTION public.bloquear_resposta_em_sessao_concluida()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_status VARCHAR;
BEGIN
    SELECT status INTO v_status
    FROM public.sessoes_simulado
    WHERE id = NEW.sessao_id;
    IF v_status = 'concluida' THEN
        RAISE EXCEPTION 'Não é possível registrar respostas em uma sessão já concluída (id: %).', NEW.sessao_id;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER antes_de_inserir_resposta
    BEFORE INSERT ON public.respostas
    FOR EACH ROW
    EXECUTE FUNCTION public.bloquear_resposta_em_sessao_concluida();

CREATE OR REPLACE FUNCTION public.finalizar_sessao()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NEW.status = 'concluida' AND NEW.finalizada_em IS NULL THEN
        NEW.finalizada_em := now();
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER ao_concluir_sessao
    BEFORE UPDATE ON public.sessoes_simulado
    FOR EACH ROW
    WHEN (OLD.status = 'em_andamento' AND NEW.status = 'concluida')
    EXECUTE FUNCTION public.finalizar_sessao();

ALTER TABLE public.profiles         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.escolas          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matriculas       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questoes         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessoes_simulado ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.respostas        ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.papel_atual()
RETURNS VARCHAR
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT papel FROM public.profiles WHERE user_id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION public.profile_id_atual()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT id FROM public.profiles WHERE user_id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION public.escola_id_do_admin()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT e.id
    FROM public.escolas e
    JOIN public.profiles p ON p.id = e.admin_id
    WHERE p.user_id = auth.uid();
$$;

CREATE POLICY aluno_visualizar_proprio_perfil ON public.profiles
    FOR SELECT
    USING (
        user_id = auth.uid()
        OR public.papel_atual() IN ('admin_escolar', 'admin_global')
    );

CREATE POLICY aluno_atualizar_proprio_perfil ON public.profiles
    FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY admin_global_perfis ON public.profiles
    FOR ALL
    USING (public.papel_atual() = 'admin_global');

CREATE POLICY admin_escolar_propria_escola ON public.escolas
    FOR ALL
    USING (admin_id = public.profile_id_atual());

CREATE POLICY admin_global_escolas ON public.escolas
    FOR ALL
    USING (public.papel_atual() = 'admin_global');

CREATE POLICY aluno_visualizar_proprias_matriculas ON public.matriculas
    FOR SELECT
    USING (aluno_id = public.profile_id_atual());

CREATE POLICY admin_escolar_matriculas ON public.matriculas
    FOR ALL
    USING (escola_id = public.escola_id_do_admin());

CREATE POLICY admin_global_matriculas ON public.matriculas
    FOR ALL
    USING (public.papel_atual() = 'admin_global');

CREATE POLICY autenticado_visualizar_questoes ON public.questoes
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY admin_global_questoes ON public.questoes
    FOR ALL
    USING (public.papel_atual() = 'admin_global');

CREATE POLICY aluno_proprias_sessoes ON public.sessoes_simulado
    FOR ALL
    USING (aluno_id = public.profile_id_atual());

CREATE POLICY admin_escolar_visualizar_sessoes ON public.sessoes_simulado
    FOR SELECT
    USING (
        aluno_id IN (
            SELECT m.aluno_id
            FROM public.matriculas m
            WHERE m.escola_id = public.escola_id_do_admin()
        )
    );

CREATE POLICY admin_global_sessoes ON public.sessoes_simulado
    FOR ALL
    USING (public.papel_atual() = 'admin_global');

CREATE POLICY aluno_proprias_respostas ON public.respostas
    FOR ALL
    USING (
        sessao_id IN (
            SELECT id FROM public.sessoes_simulado
            WHERE aluno_id = public.profile_id_atual()
        )
    );

CREATE POLICY admin_escolar_visualizar_respostas ON public.respostas
    FOR SELECT
    USING (
        sessao_id IN (
            SELECT s.id
            FROM public.sessoes_simulado s
            JOIN public.matriculas m ON m.aluno_id = s.aluno_id
            WHERE m.escola_id = public.escola_id_do_admin()
        )
    );

CREATE POLICY admin_global_respostas ON public.respostas
    FOR ALL
    USING (public.papel_atual() = 'admin_global');