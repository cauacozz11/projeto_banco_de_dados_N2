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