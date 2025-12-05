with stage_changes as (

    select
        deal_id,
        changed_at,
        new_stage_id as stage_id 
        
    from {{ ref('stg_deal_changes') }}
    where new_stage_id is not null

),

stage_sequencing as (

    select
        deal_id,
        stage_id,
        changed_at as stage_start_at,
        
        -- Previous Stage ID, LAG used to find which stage the deal came from.
        lag(stage_id, 1) over (  partition by deal_id order by changed_at ) as previous_stage_id,

        -- Stage End At, LEAD used to find the start time of the next event, which is the end time of the current one (SCD Type 2).
        lead(changed_at, 1) over (partition by deal_id order by changed_at ) as stage_end_at
        
    from stage_changes
),

final as (

    select
        -- Surrogate Key (Unique identifier for the deal-stage sequence)
        MD5(deal_id::text || stage_start_at::text) as deal_stage_sk, deal_id,
        stage_id,
        previous_stage_id,
        stage_start_at,
        stage_end_at,

        -- days_in_stage hesaplaması
       (extract(epoch from stage_end_at) - extract(epoch from stage_start_at)) / 86400 as days_in_stage,

        -- Active Flag (TRUE if stage_end_at is NULL)
        case when stage_end_at is null then TRUE else FALSE end as is_active_stage

    from stage_sequencing
)

select * from final