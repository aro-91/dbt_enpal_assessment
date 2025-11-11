

select
    deal_id,
    date_trunc('month', change_time)::date as change_month,
    changed_field_key,
    new_value AS stage_id
from "postgres"."public"."deal_changes"
where changed_field_key = 'stage_id'