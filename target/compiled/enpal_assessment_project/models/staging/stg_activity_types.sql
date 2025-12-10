

select
    id::int as id,
    "name" as name,
    active as active,
    "type" as type
from "postgres"."public"."activity_types"