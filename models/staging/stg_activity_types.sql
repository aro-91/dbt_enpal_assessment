-- This staging model cleans up and standardizes the public.activity_types table.
-- It renames 'id' and 'name' to be more descriptive.
SELECT
    id AS activity_type_id,
    trim(lower(type)) as activity_key,
    active as is_active,
    "name" AS activity_type_name
FROM {{ source('raw', 'activity_types') }}