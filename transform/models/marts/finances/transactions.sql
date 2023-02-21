{{
  config(
    materialized = 'incremental',
    unique_key = 'transaction_id',
    incremental_strategy = 'delete+insert',
  )
}}

WITH 

transactions_unioned AS (
SELECT dt.transaction_id,
       dt.date,
       dt.amount,
       dt.description,
       dt.currency,
       dt.account,
       CAST(NULL AS DATE) AS bill_month,
       'Debit' AS transaction_type
  FROM {{ ref('int_debit_transactions_unioned') }} AS dt

 UNION ALL

SELECT ct.transaction_id,
       ct.date,
       ct.amount,
       ct.description,
       ct.currency,
       ct.account,
       ct.bill_month,
       'Credit' AS transaction_type
  FROM {{ ref('int_credit_transactions_unioned') }} AS ct
),

final AS (
SELECT t.transaction_id,
       t.date,
       t.amount,
       t.description,
       t.currency,
       t.account,
       t.bill_month,
       t.transaction_type,
       COALESCE(tcg.category, NULL) AS category,
       COALESCE(tcg.category_source, NULL) AS category_source
  FROM transactions_unioned AS t
       LEFT JOIN {{ ref('stg_classifier__transactions_category_guesses') }} AS tcg
       ON tcg.transaction_id = t.transaction_id

{% if is_incremental() %}

       LEFT JOIN {{ this }} AS this
       ON this.transaction_id = t.transaction_id

 WHERE this.transaction_id IS NULL -- transaction does not exist in final table
    OR (this.category_source = 'guess' OR this.category_source IS NULL) -- transaction exists, then select only guessed or null categories

{% endif %}
)

SELECT * FROM final