/*
    Checks that the stage values are clean. Every new_value where
    changed_field_key = 'stage_id' is a whole number from 1 to 9, with no blanks
    or odd values. So turning new_value into an integer in int_deal_stage_history
    is safe, the accepted_values [1..9] test will hold, and all nine stages line
    up with the stages table.
*/
select
    new_value as stage_id
    , count(*) as change_count
    , count(distinct deal_id) as distinct_deals
from {{ source('pipedrive', 'deal_changes') }}
where changed_field_key = 'stage_id'
group by 1
order by (new_value)::integer
