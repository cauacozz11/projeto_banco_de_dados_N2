
CREATE TABLE profiles (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL UNIQUE REFERENCES auth_users (id) ON DELETE CASCADE,
    nome_completo   VARCHAR NOT NULL,
    papel           VARCHAR NOT NULL DEFAULT 'aluno'
                    CHECK (papel IN ('aluno', 'admin_escolar', 'admin_global')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


CREATE TABLE escolas (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome        VARCHAR NOT NULL,
    cnpj        VARCHAR NOT NULL UNIQUE,
    admin_id    UUID NOT NULL REFERENCES profiles (id),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


CREATE TABLE matriculas (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aluno_id    UUID NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
    escola_id   UUID NOT NULL REFERENCES escolas (id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (aluno_id, escola_id)
);

CREATE TABLE questoes (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero        INT NOT NULL,
    enunciado     JSONB NOT NULL,
    alternativas  JSONB NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);


CREATE TABLE sessoes_simulado (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aluno_id        UUID NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
    status          VARCHAR NOT NULL DEFAULT 'em_andamento'
                    CHECK (status IN ('em_andamento', 'concluida')),
    total_questoes  INT NOT NULL DEFAULT 0,
    total_acertos   INT NOT NULL DEFAULT 0,
    iniciada_em     TIMESTAMPTZ NOT NULL DEFAULT now(),
    finalizada_em   TIMESTAMPTZ
);

CREATE TABLE respostas (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sessao_id             UUID NOT NULL REFERENCES sessoes_simulado (id) ON DELETE CASCADE,
    questao_id            UUID NOT NULL REFERENCES questoes (id) ON DELETE CASCADE,
    alternativa_escolhida INT NOT NULL,
    acertou               BOOLEAN NOT NULL,
    respondida_em         TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (sessao_id, questao_id)
);