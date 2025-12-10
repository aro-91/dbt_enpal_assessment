with deal_changes as (
    select * from {{ ref('stg_deal_changes') }}
),

stages as (
    select * from {{ ref('stg_stages') }}
),

stage_events as (
    select
        dc.deal_id,
        dc.change_timestamp,
        cast(dc.new_value as integer) as stage_id,
        s.stage_name,
        to_char(date_trunc('month', dc.change_timestamp), 'YYYY-MM') as event_month
    from deal_changes dc
    left join stages s on cast(dc.new_value as integer) = s.stage_id
    where dc.field_key = 'stage_id'
)

select * from stage_events
