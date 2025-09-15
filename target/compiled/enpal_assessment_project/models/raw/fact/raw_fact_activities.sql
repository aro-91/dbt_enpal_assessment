-- Staging layer model for activity
-- Cleans and standardizes activity data




with cleaned as (
   select
       activity_id,
       type,
       assigned_to_user,
       deal_id,
       done,
       due_to,
       -- Date derived fields
       extract(month from due_to) as due_month,
       extract(year from due_to) as due_year,
       to_char(date_trunc('month', due_to), 'yyyy-mm') as due_month_year,
       current_date AS load_date
   from "postgres"."public"."activity"
   
)

select * 
from cleaned