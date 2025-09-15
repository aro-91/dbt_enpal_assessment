-- Intermediate model for mapping activities to funnel steps
-- Maps activities to their corresponding sales funnel stages





with 
-- Map activities to funnel steps based on activity type
activity_funnel_mapping as (
   select
       a.activity_id,
       a.type as activity_type,
       at.name,
       a.assigned_to_user,
       a.deal_id,
       a.done as is_completed,
       a.due_to as due_date,
       
/*    Inputs:
        - done_column (string): column name that indicates if the task is completed
        - due_to_column (string): column name with the due timestamp

      Output:
        - A string: 'Completed', 'Overdue', or 'Pending'
    */
    case
        when a.done = true then 'Completed'
        when a.due_to < current_timestamp then 'Overdue'
        else 'Pending'
    end
 as activity_status,
       a.due_month,
       a.due_year,
       a.due_month_year
   from "postgres"."pipedrive_analytics"."raw_fact_activities" a
   left join "postgres"."pipedrive_analytics"."raw_dim_activity_types" at
   on a.type = at.type
)


select * 
from activity_funnel_mapping