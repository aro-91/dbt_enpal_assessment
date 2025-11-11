{{ config(materialized='view') }}

select
    id as user_id,
    name as user_name,
    email
from {{ source('postgres_public', 'users') }}
