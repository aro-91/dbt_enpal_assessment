
  
    

  create  table "postgres"."pipedrive_analytics"."int_deal_stage_progression__dbt_tmp"
  
  
    as
  
  (
    -- Intermediate model for deal stage progression
-- Tracks deals as they move through the sales funnel





with 

-- Get stage changes only
stage_changes as (
   select
       deal_id,
       change_time,
       CAST(new_value as int) as new_stage_id,
       change_month_year
   from "postgres"."pipedrive_analytics"."raw_fact_deal_changes"
   where changed_field_key = 'stage_id'
),

-- Get all stage transitions
stage_transitions as (
   select
       deal_id,
       change_time,
       new_stage_id,
       change_month_year,
       lag(new_stage_id) over (partition by deal_id order by change_time) as previous_stage_id,
       lead(new_stage_id) over (partition by deal_id order by change_time) as next_stage_id
   from stage_changes
),


-- Join with stage names
final as (
   select
       st.deal_id,
       st.change_time,
       st.new_stage_id,
       st.previous_stage_id,
       st.next_stage_id,
       s_current.stage_name,
       -- Add current and previous states
       s_previous.stage_name as previous_stage,
       s_next.stage_name as next_stage,
       -- Add deal progression flags
       case when st.previous_stage_id is null then true else false end as is_deal_start,
       case when st.next_stage_id is null then true else false end as is_deal_end,
       -- Date time fields
       st.change_month_year, 
       extract(year from st.change_time) as change_year,
       extract(month from st.change_time) as change_month
   from stage_transitions st
   left join "postgres"."pipedrive_analytics"."raw_dim_stages" s_current
       on st.new_stage_id = s_current.stage_id
   left join "postgres"."pipedrive_analytics"."raw_dim_stages" s_previous
       on st.previous_stage_id = s_previous.stage_id
   left join "postgres"."pipedrive_analytics"."raw_dim_stages" s_next
       on st.next_stage_id = s_next.stage_id
)


select * 
from final
  );
  