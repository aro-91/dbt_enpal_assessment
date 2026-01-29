with add_time_changes as (
    select
        deal_id,
        changed_at,
        row_number() over (
            partition by deal_id
            order by changed_at
        ) as rn
    from {{ ref('stg_deal_changes') }}
    where changed_field_key = 'add_time'
)

select
    deal_id,
    changed_at as created_at,
    date_trunc('month', changed_at)::date as created_month
from add_time_changes
where rn = 1
