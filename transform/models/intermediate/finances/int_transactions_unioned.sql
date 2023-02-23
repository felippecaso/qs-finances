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