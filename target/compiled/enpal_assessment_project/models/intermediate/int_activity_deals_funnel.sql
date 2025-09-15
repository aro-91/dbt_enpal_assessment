-- Intermediate model for combining deal stages with activities data




with deal_stage as (

    select deal_id,
           new_stage_id as funnel_step,
           stage_name as kpi_name,
           change_month_year as month_year,
           '"postgres"."pipedrive_analytics"."int_deal_stage_progression"'as source

    from "postgres"."pipedrive_analytics"."int_deal_stage_progression"

),

activity_funnel as (
    select deal_id,
        
    /*
      Input:
        - name_column (string): The column name containing the activity name (e.g., 'Sales Call 1')

      Output:
        - Numeric value representing the funnel step for that activity
    */
    case
        when name = 'Sales Call 1' then 2.1
        when name = 'Sales Call 2' then 3.1
        when name = 'Follow Up Call' then 8
        when name = 'After Close Call' then 9
    end
 as funnel_step,
        
    /*
      Input:
        - name_column (string): name of the column to apply the mapping on

      Output:
        - A string: the standardized KPI name
    */
    
    case
        when name in ('Sales Call 1', 'Sales Call 2') then name
        when name = 'Follow Up Call' then 'Follow-up/Customer Success'
        when name = 'After Close Call' then 'Renewal/Expansion'
        else NULL
    end
 as kpi_name,
        due_month_year as month_year,
        '"postgres"."pipedrive_analytics"."int_activity_funnel_mapping"'as source
    from "postgres"."pipedrive_analytics"."int_activity_funnel_mapping"
),

funnel_union as (
    
    select * from deal_stage

    union all 
   
    select * from activity_funnel

)

select *
from funnel_union