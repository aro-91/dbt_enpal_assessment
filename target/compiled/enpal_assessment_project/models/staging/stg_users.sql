

select
    id::int as id,
    "name" as name,
    email as email,
    modified::timestamp as modified
from "postgres"."public"."users"