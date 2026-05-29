SELECT
    e.nome                  AS escola,
    COUNT(m.aluno_id)       AS total_alunos
FROM escolas e
LEFT JOIN matriculas m ON m.escola_id = e.id
GROUP BY e.id, e.nome
ORDER BY total_alunos DESC;
SELECT
    p.id             AS profile_id,
    u.id             AS user_id,
    p.nome_completo
FROM profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE p.papel = 'aluno'
  AND NOT EXISTS (
      SELECT 1
      FROM sessoes_simulado s
      WHERE s.aluno_id = p.id
  )
ORDER BY p.nome_completo;
SELECT
    p.nome_completo             AS aluno,
    r.alternativa_escolhida,
    r.acertou
FROM respostas r
JOIN sessoes_simulado s  ON s.id       = r.sessao_id
JOIN profiles p          ON p.id       = s.aluno_id
JOIN questoes q          ON q.id       = r.questao_id
WHERE q.numero = 45
  AND p.id IN (
      SELECT m.aluno_id
      FROM matriculas m
      JOIN escolas e ON e.id = m.escola_id
      WHERE e.cnpj = '12.345.678/0001-99'
  )
ORDER BY p.nome_completo;
SELECT
    e.nome                                                          AS escola,
    ROUND(
        SUM(s.total_acertos)::numeric
        / NULLIF(SUM(s.total_questoes), 0) * 100
    , 2)                                                            AS taxa_acerto_pct
FROM escolas e
JOIN matriculas m        ON m.escola_id = e.id
JOIN sessoes_simulado s  ON s.aluno_id  = m.aluno_id
WHERE s.status = 'concluida'
GROUP BY e.id, e.nome
ORDER BY taxa_acerto_pct DESC;
SELECT
    s.id                                AS sessao_id,
    s.total_questoes                    AS total_questoes_armazenado,
    COUNT(r.id)                         AS total_questoes_real,
    s.total_acertos                     AS total_acertos_armazenado,
    COUNT(r.id) FILTER (WHERE r.acertou = true) AS total_acertos_real
FROM sessoes_simulado s
LEFT JOIN respostas r ON r.sessao_id = s.id
WHERE s.status = 'concluida'
GROUP BY s.id, s.total_questoes, s.total_acertos
HAVING
    s.total_questoes <> COUNT(r.id)
    OR s.total_acertos <> COUNT(r.id) FILTER (WHERE r.acertou = true)
ORDER BY s.id;
SELECT
    p.nome_completo,
    SUM(s.total_acertos)    AS total_acertos,
    SUM(s.total_questoes)   AS total_questoes
FROM profiles p
JOIN sessoes_simulado s ON s.aluno_id = p.id
WHERE s.status = 'concluida'
GROUP BY p.id, p.nome_completo
HAVING SUM(s.total_questoes) >= 100
ORDER BY total_acertos DESC
LIMIT 5;