WITH deal_funnel_stages AS (
  SELECT * FROM {{ ref('fct_deal_funnel_stages') }}
),

date_range AS (
  SELECT
    MIN(DATE_TRUNC('MONTH', modified_at))::DATE AS min_date,
    MAX(DATE_TRUNC('MONTH', modified_at))::DATE AS max_date
  FROM deal_funnel_stages
),

date_series AS (
  SELECT generate_series(min_date, max_date, '1 MONTH')::DATE AS calendar_month_start
  FROM date_range
),

funnel_steps AS (
  SELECT
    funnel_step::INT AS funnel_step,
    COALESCE(funnel_sub_step, 0)::INT AS funnel_sub_step,
    TRIM(funnel_step_name) AS funnel_step_name
  FROM {{ ref('seed_sales_funnel_steps_order') }}
  GROUP BY 1, 2, 3
),

stage_deals AS (
  SELECT
    DATE_TRUNC('MONTH', modified_at)::DATE AS stage_month,
    stage_id,
    stage_name,
    COUNT(DISTINCT deal_id) AS deals_count,
    MAX(max_updated_at) AS _last_synced
  FROM deal_funnel_stages
  GROUP BY 1, 2, 3
),

activity_deals AS (
  SELECT
    DATE_TRUNC('MONTH', due_at)::DATE AS activity_month,
    activity_name,
    activity_type,
    COUNT(DISTINCT deal_id) AS deals_count,
    SUM(is_completed::INT) AS completed_deal_activities,
    MAX(max_updated_at) AS _last_synced
  FROM {{ ref('fct_deal_activities') }}
  GROUP BY 1, 2, 3
),

final AS (
  SELECT
    TO_CHAR(date_series.calendar_month_start, 'YYYY-MM') AS month,

    -- funnel steps and kpi names
    funnel_steps.funnel_step_name AS kpi_name,
    CASE
      WHEN funnel_steps.funnel_sub_step = 0 THEN funnel_steps.funnel_step::VARCHAR
      ELSE funnel_steps.funnel_step::VARCHAR || '.' || funnel_steps.funnel_sub_step::VARCHAR
    END AS funnel_step,

    -- count of deals in each stage
    COALESCE(stage_deals.deals_count, activity_deals.deals_count,0) AS deals_count
  FROM funnel_steps
  CROSS JOIN date_series
  LEFT JOIN stage_deals
    ON
      stage_deals.stage_id = funnel_steps.funnel_step
      AND stage_deals.stage_month = date_series.calendar_month_start
  LEFT JOIN activity_deals
    ON
      activity_deals.activity_name = funnel_steps.funnel_step_name
      AND activity_deals.activity_month = date_series.calendar_month_start
  GROUP BY 1, 2, 3, 4
  ORDER BY 1, 2
)

SELECT * FROM final
