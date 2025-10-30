{{ config(materialized='table') }}

with done_calls as (
    select
        a.deal_id,
        a.activity_id,
        a.activity_type_key,
        a.due_ts::timestamp as call_ts
    from {{ ref('stg_activity') }} a
    where a.is_done = true
      and a.deal_id is not null
),
mapped as (
    select
        deal_id,
        case
          when activity_type_key = 'meeting' then 'Sales Call 1'
          when activity_type_key = 'sc_2'    then 'Sales Call 2'
          else null
        end as call_name,
        call_ts
    from done_calls
),
filtered as (
    select * from mapped where call_name is not null
),
first_per_deal_call as (
    select
        deal_id,
        call_name,
        min(call_ts) as first_call_ts
    from filtered
    group by 1,2
)
select * from first_per_deal_call
