WITH
source AS (
SELECT * FROM {{ source('finances', 'caju_transactions') }}
),

returned_transaction_ids AS (
SELECT REPLACE(REPLACE(s.tipo_de_acao, 'Estorno da compra ', ''), ' feita no cartão', '') AS returned_deal_id
  FROM source AS s
 WHERE s.tipo_de_acao LIKE 'Estorno da compra%'
),

transactions AS (
SELECT s.date::DATE AS date,
       (CASE 
         WHEN s.acao = 'Débito' THEN -1*s.valor 
         WHEN s.acao = 'Crédito' THEN s.valor 
       END) AS amount,
       CONCAT(s.categoria_destino, ' - ', s.estabelecimento) AS description,
       'BRL' AS currency,
       'Caju' AS account
  FROM source AS s
        LEFT JOIN returned_transaction_ids AS rt
        ON rt.returned_deal_id = s.deal_id
  WHERE s.status = 'Completo'
    AND rt.returned_deal_id IS NULL
    AND s.tipo_de_acao != 'Transferência de saldo'
    AND s.tipo_de_acao NOT LIKE 'Estorno da compra%'
)

SELECT MD5(CONCAT(ROW_NUMBER() OVER (PARTITION BY t.date, t.amount, t.account ORDER BY t.description), '-', t.date, '-', t.amount, '-', t.account)) AS transaction_id,
       t.date,
       t.amount,
       t.description,
       t.currency,
       t.account
  FROM transactions AS t