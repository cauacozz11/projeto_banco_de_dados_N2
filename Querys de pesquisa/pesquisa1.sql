SELECT
    e.nome                  AS escola,
    COUNT(m.aluno_id)       AS total_alunos
FROM escolas e
LEFT JOIN matriculas m ON m.escola_id = e.id
GROUP BY e.id, e.nome
ORDER BY total_alunos DESC;
