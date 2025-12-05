with stages as (

    select 
        stage_id,
        stage_name
    from {{ ref('stg_stages') }}

),

funnel_mapping as (

    select
        stage_id,
        stage_name,
        
        -- Map the raw stage names to the business-defined funnel steps
        case 
            when stage_name = 'Lead Generation' then 'Step 1: Lead Generation'
            when stage_name = 'Qualified Lead' then 'Step 2: Qualified Lead'
            when stage_name like '%Sales Call 1%' then 'Step 2.1: Sales Call 1'
            when stage_name = 'Needs Assessment' then 'Step 3: Needs Assessment'
            when stage_name like '%Sales Call 2%' then 'Step 3.1: Sales Call 2'
            when stage_name = 'Proposal/Quote Preparation' then 'Step 4: Proposal/Quote Preparation'
            when stage_name = 'Negotiation' then 'Step 5: Negotiation'
            when stage_name = 'Closing' then 'Step 6: Closing'
            when stage_name = 'Implementation/Onboarding' then 'Step 7: Implementation/Onboarding'
            when stage_name = 'Follow-up/Customer Success' then 'Step 8: Follow-up/Customer Success'
            when stage_name = 'Renewal/Expansion' then 'Step 9: Renewal/Expansion'
            else '99: Uncategorized'
        end as funnel_step,
        
        -- Define the numerical order for correct funnel sequencing
        case 
            when stage_name = 'Lead Generation' then 10
            when stage_name = 'Qualified Lead' then 20
            when stage_name like '%Sales Call 1%' then 21
            when stage_name = 'Needs Assessment' then 30
            when stage_name like '%Sales Call 2%' then 31  
            when stage_name = 'Proposal/Quote Preparation' then 40
            when stage_name = 'Negotiation' then 50
            when stage_name = 'Closing' then 60
            when stage_name = 'Implementation/Onboarding' then 70
            when stage_name = 'Follow-up/Customer Success' then 80
            when stage_name = 'Renewal/Expansion' then 90
            else 999
        end as funnel_order

    from stages
)

select * from funnel_mapping