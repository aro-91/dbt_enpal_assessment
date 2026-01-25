-- postgres specific, might not work on other engines/databases
select distinct on (deal_id)
    deal_id,
    user_id,
    stage_id,
    stage_name,
    is_lost_deal,
    stage_start_time,
    stage_end_time,
    stage_duration_in_days
from {{ ref('int_deal_stages_history') }}
order by deal_id, stage_start_time desc
