WITH
source AS (
SELECT * FROM {{ source('finances', 'btg_investments_transactions') }}
),

transactions AS (
SELECT s.date::DATE AS date,
       s.Valor AS amount,
       s.Descricao AS description,
       'BRL' AS currency,
       'BTG Investimentos' AS account
  FROM source AS s
 WHERE s.Valor IS NOT NULL
   AND s.Descricao NOT LIKE '%Saldo Remunerado'
)

SELECT MD5(CONCAT(ROW_NUMBER() OVER (PARTITION BY t.date, t.amount, t.account ORDER BY t.description), '-', t.date, '-', t.amount, '-', t.account)) AS transaction_id,
       t.date,
       t.amount,
       t.description,
       t.currency,
       t.account
  FROM transactions AS t