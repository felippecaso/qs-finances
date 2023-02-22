SELECT * FROM {{ ref('stg_finances__itau_transactions') }}
 UNION ALL
SELECT * FROM {{ ref('stg_finances__caju_transactions') }}
 UNION ALL
SELECT * FROM {{ ref('stg_finances__nomad_transactions') }}
 UNION ALL
SELECT * FROM {{ ref('stg_finances__btg_banking_transactions') }}
 UNION ALL
SELECT * FROM {{ ref('stg_finances__btg_investments_transactions') }}