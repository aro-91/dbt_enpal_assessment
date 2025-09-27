{{ config(materialized='view') }}

WITH base AS (
    SELECT
        deal_changes.deal_id,
        -- keep raw event timestamp for tests
        deal_changes.changed_at,
        deal_changes.new_stage_id AS stage_id
    FROM {{ ref('stg_pipedrive__deal_changes') }} AS deal_changes
    WHERE
        deal_changes.changed_field_key = 'stage_id'
        AND deal_changes.new_stage_id IS NOT null
)

SELECT
    b.deal_id,
    b.changed_at,
    b.stage_id,
    date_trunc('month', b.changed_at)::date AS month,
    map_stage_to_funnel.kpi_name,
    map_stage_to_funnel.funnel_step,       -- TEXT (supports 2.1 / 3.1 etc.)
    map_stage_to_funnel.sort_order
FROM base AS b
INNER JOIN {{ ref('map_stage_to_funnel') }} AS map_stage_to_funnel
    ON b.stage_id = map_stage_to_funnel.stage_id
