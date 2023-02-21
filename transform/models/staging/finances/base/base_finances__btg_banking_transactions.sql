WITH
source AS (
SELECT * FROM {{ source('finances', 'btg_banking_transactions') }}
)

SELECT s.date::DATE AS date,
       s.Valor AS amount,
       CONCAT(s.Transacao, ' - ', s.Descricao) AS description,
       'BRL' AS currency,
       'BTG Banking' AS account
  FROM source AS s