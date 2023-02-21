WITH
source AS (
SELECT * FROM {{ source('finances', 'btg_credit_transactions') }}
),

transactions AS (
SELECT s.date,
       s.amount,
       s.description,
       'BRL' AS currency,
       'BTG Credit' AS account,
       s.bill_month
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