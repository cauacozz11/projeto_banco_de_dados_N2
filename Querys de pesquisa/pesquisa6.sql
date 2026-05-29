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