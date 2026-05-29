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