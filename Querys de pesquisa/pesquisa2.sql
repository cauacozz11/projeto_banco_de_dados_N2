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