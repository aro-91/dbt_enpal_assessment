/*
    Test: rep_deal_status_monthly has unique grain (deal_id + reporting_month)

    Why this matters:
    If the snapshot logic produces duplicates — e.g., due to multiple lost_reason
    events on the same deal in the same month — downstream aggregations will
    double-count. This test catches that before it silently corrupts KPIs.

    Expected result: 0 rows (no duplicates).
*/

select
    deal_id,
    reporting_month,
    count(*) as row_count
from {{ ref('rep_deal_status_monthly') }}
group by deal_id, reporting_month
having count(*) > 1
