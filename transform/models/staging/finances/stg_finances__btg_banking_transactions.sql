WITH
source AS (
SELECT * FROM {{ source('finances', 'btg_banking_transactions') }}
),

transactions AS (
SELECT s.date,
       s.amount,
       s.description,
       'BRL' AS currency,
       'BTG Banking' AS account
  FROM source AS s
),

unioned_transactions AS (
SELECT t.date,
       t.amount,
       t.description,
       t.currency,
       t.account,
       ROW_NUMBER() OVER (PARTITION BY t.date, t.amount, t.account ORDER BY t.description) AS rn
  FROM transactions AS t

 UNION ALL

SELECT LAST_DAY(ay.month)::DATETIME AS date,
       ay.amount AS amount,
       'Rendimento Automático' AS description,
       'BRL' AS currency,
       'BTG Banking' AS account,
       1 AS rn
  FROM {{ source('finances', 'btg_banking_automatic_yields') }} AS ay
)

SELECT MD5(CONCAT(ut.rn, '-', ut.date, '-', ut.amount, '-', ut.account)) AS transaction_id,
       ut.date,
       ut.amount,
       ut.description,
       ut.currency,
       ut.account
  FROM unioned_transactions AS ut