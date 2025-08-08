-- This model aggregates deal data into a monthly  funnel report
-- It is based on the pre-processed data from the intermediate layer.
-- Created it as table and with index for better performance

{{
    config(
    materialized='table',
    indexes=[
        {'columns': ['month'], 'unique': False}
    ]
    )
}}
    SELECT
        "month",
        kpi_name,
        funnel_step,
        COUNT(DISTINCT deal_id) AS deals_count
    FROM {{ ref("intermediate_deals_stages") }} ids
    GROUP BY 1,2,3
    ORDER BY
        "month", funnel_step

