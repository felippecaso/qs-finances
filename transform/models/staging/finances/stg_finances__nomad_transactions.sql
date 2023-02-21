WITH
source AS (
SELECT * FROM {{ source('finances', 'nomad_transactions') }}
),

transactions AS (
SELECT s.date::DATE AS date,
       s.amount AS amount,
       s.description AS description,
       'USD' AS currency,
       'Nomad' AS account
  FROM source AS s
 WHERE s.status != 'Retornado'
)

SELECT MD5(CONCAT(ROW_NUMBER() OVER (PARTITION BY t.date, t.amount, t.account ORDER BY t.description), '-', t.date, '-', t.amount, '-', t.account)) AS transaction_id,
       t.date,
       t.amount,
       t.description,
       t.currency,
       t.account
  FROM transactions AS t