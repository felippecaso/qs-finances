SELECT * FROM {{ ref('stg_finances__btg_credit_transactions') }}
 UNION ALL
SELECT * FROM {{ ref('stg_finances__nubank_transactions') }}