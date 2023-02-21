WITH source AS (
SELECT * FROM {{ source('classifier', 'transactions_category_guesses') }}
)

SELECT s.transaction_id,
       s.category,
       s.category_source
  FROM source AS s