





with validation_errors as (

    select
        activity_id, deal_id
    from "postgres"."pipedrive_analytics"."int_activity_funnel_mapping"
    group by activity_id, deal_id
    having count(*) > 1

)

select *
from validation_errors


