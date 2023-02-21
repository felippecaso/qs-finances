WITH
source AS (
SELECT * FROM {{ source('finances', 'nubank_transactions') }}
),

transactions AS (
SELECT s.date,
       s.amount,
       s.title AS description,
       'BRL' AS currency,
       'Nubank' AS account,
       DATE_TRUNC('month', s.date) AS bill_month
  FROM source AS s
)

SELECT MD5(CONCAT(ROW_NUMBER() OVER (PARTITION BY t.date, t.amount, t.account ORDER BY t.description), '-', t.date, '-', t.amount, '-', t.account)) AS transaction_id,
       t.date,
       t.amount,
       t.description,
       t.currency,
       t.account,
       t.bill_month
  FROM transactions AS t