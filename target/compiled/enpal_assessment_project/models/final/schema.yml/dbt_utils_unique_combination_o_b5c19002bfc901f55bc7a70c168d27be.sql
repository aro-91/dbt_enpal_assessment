





with validation_errors as (

    select
        month, kpi_name
    from "postgres"."pipedrive_analytics"."rep_sales_funnel_monthly"
    group by month, kpi_name
    having count(*) > 1

)

select *
from validation_errors


