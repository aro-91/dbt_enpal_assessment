{{ config(materialized='view') }}
-- Accept raw as-is; dedupe in staging
WITH base AS (
    SELECT
        activity_id::bigint AS activity_id,
        deal_id::bigint AS deal_id,
        type AS activity_type_key,
        done::boolean AS is_done,
        due_to::timestamp AS happened_at
    FROM {{ source('pipedrive','activity') }}
    -- business guard: only activities linked to a deal
    WHERE deal_id IS NOT null
),

ranked AS (
    SELECT
        b.activity_id,
        b.deal_id,
        b.activity_type_key,
        b.is_done,
        b.happened_at,
        row_number() OVER (
            PARTITION BY b.activity_id
            ORDER BY b.happened_at DESC NULLS LAST
        ) AS rn
    FROM base AS b
)

SELECT activity_id,
       deal_id,
       activity_type_key,
       is_done,
       happened_at
FROM ranked
WHERE rn = 1
