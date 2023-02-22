WITH
source AS (
SELECT * FROM {{ source('finances', 'btg_investments_transactions') }}
),

transactions AS (
SELECT s.date,
       s.amount,
       s.description,
       'BRL' AS currency,
       'BTG Investimentos' AS account
  FROM source AS s
 WHERE s.amount IS NOT NULL
   AND s.description NOT LIKE '%Saldo Remunerado'
)

SELECT MD5(CONCAT(ROW_NUMBER() OVER (PARTITION BY t.date, t.amount, t.account ORDER BY t.description), '-', t.date, '-', t.amount, '-', t.account)) AS transaction_id,
       t.date,
       t.amount,
       t.description,
       t.currency,
       t.account
  FROM transactions AS t