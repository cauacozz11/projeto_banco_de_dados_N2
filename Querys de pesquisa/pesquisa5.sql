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