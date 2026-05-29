INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data)
VALUES
  (gen_random_uuid(), 'admin.global@escola.com',  '$2a$10$placeholder', now(), now(), now(), '{"nome_completo": "Carlos Admin Global",  "papel": "admin_global"  }'::jsonb),
  (gen_random_uuid(), 'admin.escola1@escola.com', '$2a$10$placeholder', now(), now(), now(), '{"nome_completo": "Fernanda Diretora",    "papel": "admin_escolar" }'::jsonb),
  (gen_random_uuid(), 'admin.escola2@escola.com', '$2a$10$placeholder', now(), now(), now(), '{"nome_completo": "Roberto Diretor",      "papel": "admin_escolar" }'::jsonb),
  (gen_random_uuid(), 'aluno1@escola.com',        '$2a$10$placeholder', now(), now(), now(), '{"nome_completo": "Ana Souza",            "papel": "aluno"         }'::jsonb),
  (gen_random_uuid(), 'aluno2@escola.com',        '$2a$10$placeholder', now(), now(), now(), '{"nome_completo": "Bruno Lima",           "papel": "aluno"         }'::jsonb),
  (gen_random_uuid(), 'aluno3@escola.com',        '$2a$10$placeholder', now(), now(), now(), '{"nome_completo": "Carla Mendes",         "papel": "aluno"         }'::jsonb),
  (gen_random_uuid(), 'aluno4@escola.com',        '$2a$10$placeholder', now(), now(), now(), '{"nome_completo": "Diego Ramos",          "papel": "aluno"         }'::jsonb),
  (gen_random_uuid(), 'aluno5@escola.com',        '$2a$10$placeholder', now(), now(), now(), '{"nome_completo": "Eduarda Costa",        "papel": "aluno"         }'::jsonb),
  (gen_random_uuid(), 'aluno6@escola.com',        '$2a$10$placeholder', now(), now(), now(), '{"nome_completo": "Felipe Nunes",         "papel": "aluno"         }'::jsonb);

INSERT INTO escolas (nome, cnpj, admin_id)
VALUES
  ('Escola Estadual São Paulo',    '11.222.333/0001-44',
   (SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'admin.escola1@escola.com')),

  ('Colégio Municipal Rio Verde',  '55.666.777/0001-88',
   (SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'admin.escola2@escola.com'));

INSERT INTO matriculas (aluno_id, escola_id)
VALUES
  ((SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'aluno1@escola.com'),
   (SELECT id FROM escolas WHERE cnpj = '11.222.333/0001-44')),

  ((SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'aluno2@escola.com'),
   (SELECT id FROM escolas WHERE cnpj = '11.222.333/0001-44')),

  ((SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'aluno3@escola.com'),
   (SELECT id FROM escolas WHERE cnpj = '11.222.333/0001-44')),

  ((SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'aluno4@escola.com'),
   (SELECT id FROM escolas WHERE cnpj = '55.666.777/0001-88')),

  ((SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'aluno5@escola.com'),
   (SELECT id FROM escolas WHERE cnpj = '55.666.777/0001-88')),

  ((SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'aluno6@escola.com'),
   (SELECT id FROM escolas WHERE cnpj = '55.666.777/0001-88'));

INSERT INTO questoes (numero, enunciado, alternativas)
VALUES
  (1,
   '{"texto": "Qual é o resultado de 2 + 2?", "disciplina": "Matemática", "dificuldade": "facil"}'::jsonb,
   '[{"indice": 0, "texto": "3",  "correta": false}, {"indice": 1, "texto": "4",  "correta": true},  {"indice": 2, "texto": "5",  "correta": false}, {"indice": 3, "texto": "22", "correta": false}]'::jsonb),

  (2,
   '{"texto": "Qual planeta é o mais próximo do Sol?", "disciplina": "Ciências", "dificuldade": "facil"}'::jsonb,
   '[{"indice": 0, "texto": "Vênus",    "correta": false}, {"indice": 1, "texto": "Terra",    "correta": false}, {"indice": 2, "texto": "Mercúrio", "correta": true},  {"indice": 3, "texto": "Marte",    "correta": false}]'::jsonb),

  (3,
   '{"texto": "Quem escreveu Dom Casmurro?", "disciplina": "Literatura", "dificuldade": "medio"}'::jsonb,
   '[{"indice": 0, "texto": "José de Alencar",         "correta": false}, {"indice": 1, "texto": "Machado de Assis",       "correta": true},  {"indice": 2, "texto": "Euclides da Cunha",      "correta": false}, {"indice": 3, "texto": "Graciliano Ramos",        "correta": false}]'::jsonb),

  (4,
   '{"texto": "Qual a fórmula química da água?", "disciplina": "Química", "dificuldade": "facil"}'::jsonb,
   '[{"indice": 0, "texto": "CO2",  "correta": false}, {"indice": 1, "texto": "H2O",  "correta": true},  {"indice": 2, "texto": "O2",   "correta": false}, {"indice": 3, "texto": "NaCl", "correta": false}]'::jsonb),

  (5,
   '{"texto": "Em que ano o Brasil proclamou a República?", "disciplina": "História", "dificuldade": "medio"}'::jsonb,
   '[{"indice": 0, "texto": "1822", "correta": false}, {"indice": 1, "texto": "1888", "correta": false}, {"indice": 2, "texto": "1889", "correta": true},  {"indice": 3, "texto": "1900", "correta": false}]'::jsonb),

  (6,
   '{"texto": "Qual é a capital da França?", "disciplina": "Geografia", "dificuldade": "facil"}'::jsonb,
   '[{"indice": 0, "texto": "Londres", "correta": false}, {"indice": 1, "texto": "Berlim",  "correta": false}, {"indice": 2, "texto": "Roma",    "correta": false}, {"indice": 3, "texto": "Paris",   "correta": true}]'::jsonb),

  (7,
   '{"texto": "Quantos lados tem um hexágono?", "disciplina": "Matemática", "dificuldade": "facil"}'::jsonb,
   '[{"indice": 0, "texto": "5", "correta": false}, {"indice": 1, "texto": "6", "correta": true},  {"indice": 2, "texto": "7", "correta": false}, {"indice": 3, "texto": "8", "correta": false}]'::jsonb),

  (8,
   '{"texto": "Qual organela é responsável pela fotossíntese?", "disciplina": "Biologia", "dificuldade": "medio"}'::jsonb,
   '[{"indice": 0, "texto": "Mitocôndria", "correta": false}, {"indice": 1, "texto": "Ribossomo",   "correta": false}, {"indice": 2, "texto": "Cloroplasto", "correta": true},  {"indice": 3, "texto": "Núcleo",      "correta": false}]'::jsonb),

  (9,
   '{"texto": "Qual é o maior oceano do mundo?", "disciplina": "Geografia", "dificuldade": "facil"}'::jsonb,
   '[{"indice": 0, "texto": "Atlântico", "correta": false}, {"indice": 1, "texto": "Índico",    "correta": false}, {"indice": 2, "texto": "Ártico",    "correta": false}, {"indice": 3, "texto": "Pacífico",  "correta": true}]'::jsonb),

  (10,
   '{"texto": "Qual lei aboliu a escravidão no Brasil?", "disciplina": "História", "dificuldade": "medio"}'::jsonb,
   '[{"indice": 0, "texto": "Lei Saraiva",           "correta": false}, {"indice": 1, "texto": "Lei Áurea",             "correta": true},  {"indice": 2, "texto": "Lei do Ventre Livre",    "correta": false}, {"indice": 3, "texto": "Lei Eusébio de Queirós", "correta": false}]'::jsonb);

WITH sessao AS (
  INSERT INTO sessoes_simulado (aluno_id)
  VALUES ((SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'aluno1@escola.com'))
  RETURNING id
),
resps AS (
  INSERT INTO respostas (sessao_id, questao_id, alternativa_escolhida, acertou)
  SELECT s.id, q.id, v.alt, v.acertou
  FROM sessao s
  CROSS JOIN (VALUES
    (1, 1, true),
    (2, 2, true),
    (3, 1, true),
    (4, 1, true),
    (5, 0, false)
  ) AS v(numero, alt, acertou)
  JOIN questoes q ON q.numero = v.numero
)
UPDATE sessoes_simulado
SET status = 'concluida'
WHERE id = (SELECT id FROM sessao);

WITH sessao AS (
  INSERT INTO sessoes_simulado (aluno_id)
  VALUES ((SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'aluno2@escola.com'))
  RETURNING id
)
INSERT INTO respostas (sessao_id, questao_id, alternativa_escolhida, acertou)
SELECT s.id, q.id, v.alt, v.acertou
FROM sessao s
CROSS JOIN (VALUES
  (1, 1, true),
  (2, 0, false),
  (6, 3, true)
) AS v(numero, alt, acertou)
JOIN questoes q ON q.numero = v.numero;

WITH sessao AS (
  INSERT INTO sessoes_simulado (aluno_id)
  VALUES ((SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'aluno3@escola.com'))
  RETURNING id
),
resps AS (
  INSERT INTO respostas (sessao_id, questao_id, alternativa_escolhida, acertou)
  SELECT s.id, q.id, v.alt, v.acertou
  FROM sessao s
  CROSS JOIN (VALUES
    (1,  1, true),
    (2,  2, true),
    (3,  1, true),
    (4,  0, false),
    (5,  2, true),
    (6,  3, true),
    (7,  1, true),
    (8,  0, false),
    (9,  3, true),
    (10, 0, false)
  ) AS v(numero, alt, acertou)
  JOIN questoes q ON q.numero = v.numero
)
UPDATE sessoes_simulado
SET status = 'concluida'
WHERE id = (SELECT id FROM sessao);

WITH sessao AS (
  INSERT INTO sessoes_simulado (aluno_id)
  VALUES ((SELECT p.id FROM profiles p JOIN auth.users u ON u.id = p.user_id WHERE u.email = 'aluno4@escola.com'))
  RETURNING id
)
INSERT INTO respostas (sessao_id, questao_id, alternativa_escolhida, acertou)
SELECT s.id, q.id, v.alt, v.acertou
FROM sessao s
CROSS JOIN (VALUES
  (1, 1, true),
  (3, 0, false)
) AS v(numero, alt, acertou)
JOIN questoes q ON q.numero = v.numero;