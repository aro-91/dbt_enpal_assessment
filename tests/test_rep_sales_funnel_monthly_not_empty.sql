select 1
from {{ ref('rep_sales_funnel_monthly') }}
having count(*) = 0
