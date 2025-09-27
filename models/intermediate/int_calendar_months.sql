-- INTERMEDIATE: month spine
-- Goal: one row per month from the earliest event to now (used to left-join and show zero-months)

{{ config(materialized='view') }}

WITH bounds AS (
    SELECT
    -- pick the earliest month across both event sources (stage changes & activities)
        date_trunc('month', least(
            coalesce(
                (
                    SELECT min(changed_at)
                    FROM {{ ref('stg_pipedrive__deal_changes') }}
                ),
                now()
            ),
            coalesce(
                (
                    SELECT min(happened_at)
                    FROM {{ ref('stg_pipedrive__activity') }}
                ),
                now()
            )
        ))::date AS min_month,
        date_trunc('month', now())::date AS max_month
),

months AS (
    -- generate a contiguous month series (inclusive)
    SELECT gs::date AS month
    FROM bounds AS b
    CROSS JOIN
        generate_series(b.min_month, b.max_month, interval '1 month') AS gs
)

SELECT month FROM months
