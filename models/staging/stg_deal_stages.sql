-- This staging model cleans up and standardizes the public.stages table.
-- It renames 'stage_id' and 'stage_name' for clarity.
SELECT
    stage_id::varchar(20),
    stage_name::varchar(50)
FROM {{ source('raw', 'stages') }}