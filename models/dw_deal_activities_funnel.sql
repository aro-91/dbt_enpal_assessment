SELECT
    HASHTEXT(deal_id || '_' || activity_type_id) AS deal_activity_type_id,
    deal_id,
    activity_type_id,
    MIN(due_to_timestamp) AS activity_type_first_done_timestamp
FROM {{ ref('fct_activity') }}
WHERE is_done
GROUP BY 1, 2, 3