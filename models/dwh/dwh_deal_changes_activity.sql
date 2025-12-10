with deal_changes as (
    select 
        dc.deal_id::int as deal_id,
        dc.new_value::int as stage_id,
        st.stage_name as stage_name,
        change_time as change_time
    from {{ ref('stg_deal_changes') }} dc 
    left join {{ ref('stg_stages')}} st on dc.new_value::int = st.stage_id 
    where changed_field_key = 'stage_id'), 
calls_made as (
select 
    ac.deal_id as deal_id,
    case
        when ty.name = 'Sales Call 1' then 2.1
        when ty.name = 'Sales Call 2' then 3.1 end as stage_id,
    ty.name as stage_name,
    ac.due_to as change_time
from {{ ref('stg_activity')}} ac 
left join {{ ref('stg_activity_types')}} ty on ac.type = ty.type
where (ty.name = 'Sales Call 1' OR ty.name = 'Sales Call 2') and done = true)
select * from deal_changes
union
select * from calls_made
