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
  FROM {{ ref('int_transactions_unioned') }} AS t
       LEFT JOIN {{ ref('transactions_category_guesses') }} AS tcg
       ON tcg.transaction_id = t.transaction_id