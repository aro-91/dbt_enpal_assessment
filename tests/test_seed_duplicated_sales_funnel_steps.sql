WITH unqiue_funnel_steps AS (
  SELECT
    funnel_step,
    funnel_sub_step,
    funnel_step_name
  FROM {{ ref('seed_sales_funnel_steps_order') }}
  GROUP BY 1, 2, 3
),

final AS (
  SELECT
    funnel_step,
    funnel_sub_step,
    funnel_step_name
  FROM unqiue_funnel_steps
  GROUP BY 1, 2, 3
  HAVING COUNT(*) > 1
)

SELECT * FROM final