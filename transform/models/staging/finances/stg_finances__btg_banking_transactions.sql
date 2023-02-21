WITH 
unioned_transactions AS (
SELECT t.date::DATE AS date,
       t.amount,
       t.description,
       t.currency,
       t.account,
       ROW_NUMBER() OVER (PARTITION BY t.date::DATE, t.amount, t.account ORDER BY t.description) AS rn
  FROM {{ ref('base_finances__btg_banking_transactions') }} AS t

 UNION ALL

SELECT LAST_DAY(ay.month)::DATE AS date,
       ay.amount AS amount,
       'Rendimento Automático' AS description,
       'BRL' AS currency,
       'BTG Banking' AS account,
       1 AS rn
  FROM {{ ref('btg_banking_automatic_yields') }} AS ay
)

SELECT MD5(CONCAT(ut.rn, '-', ut.date, '-', ut.amount, '-', ut.account)) AS transaction_id,
       ut.date,
       ut.amount,
       ut.description,
       ut.currency,
       ut.account
  FROM unioned_transactions AS ut