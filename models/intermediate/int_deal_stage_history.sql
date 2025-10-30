{{ config(materialized='table') }}

with stage_changes as (
    select
        dc.deal_id,
        dc.change_time::timestamp as stage_change_ts,
        dc.new_value::int        as stage_id
    from {{ ref('stg_deal_changes') }} dc
    where dc.changed_field_key = 'stage_id'
      and dc.deal_id is not null
      and dc.new_value is not null  
),
dedup_first_entry as (
    select
        deal_id,
        stage_id,
        stage_change_ts,
        row_number() over (
            partition by deal_id, stage_id
            order by stage_change_ts
        ) as rn
    from stage_changes
),
joined as (
    select
        d.deal_id,
        d.stage_id,
        s.stage_name,
        d.stage_change_ts       as first_entered_at
    from dedup_first_entry d
    join {{ ref('stg_stages') }} s
      on s.stage_id = d.stage_id
    where d.rn = 1
)
select * from joined
