{{ config(materialized='view') }}

select
    activity_id::int as activity_id,
    "type" as "type",
    assigned_to_user as assigned_to_user,
    deal_id as deal_id,
    done as done,
    due_to::timestamp as due_to
from {{ source('crm', 'activity') }}