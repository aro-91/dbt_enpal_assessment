WITH json_input AS (
  SELECT
    '[{"a_key": "a_value"},{"b_key":"b_value"}]'::JSONB AS json_field,
    '[]'::JSONB AS empty_jsonb_field
),

test_return_null_for_missing_key AS (
  SELECT
    {{ jsonb_extract_null_missing('json_field', 'missing_key') }} AS result FROM json_input
),

test_return_null_for_key_empty_json AS (
  SELECT
    {{ jsonb_extract_null_missing('empty_jsonb_field', 'missing_key') }} AS result FROM json_input
),

test_return_value_for_correct_key AS (
  SELECT
    {{ jsonb_extract_null_missing('json_field', 'a_key') }} AS result FROM json_input
),

final AS (
  -- The function should return null when the key does not exist in the json field.
  SELECT result
  FROM test_return_null_for_missing_key
  WHERE result IS NOT NULL
  -- The function should return null when the key does not exist in the empty json field.
  UNION ALL
  SELECT result
  FROM test_return_null_for_key_empty_json
  WHERE result IS NOT NULL
  -- The function should return expected value when the key exists in the json field.
  UNION ALL
  SELECT result
  FROM test_return_value_for_correct_key
  WHERE result != 'a_value'
)

SELECT * FROM final
