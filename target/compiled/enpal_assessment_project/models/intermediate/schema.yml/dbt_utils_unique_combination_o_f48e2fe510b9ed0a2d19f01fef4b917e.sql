





with validation_errors as (

    select
        change_time, deal_id
    from "postgres"."pipedrive_analytics"."int_deal_stage_progression"
    group by change_time, deal_id
    having count(*) > 1

)

select *
from validation_errors


