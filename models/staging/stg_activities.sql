-- This staging model cleans up and standardizes data from the public.activity table.
-- It renames columns for clarity and casts data types where necessary.
SELECT
    activity_id,
    trim(lower(type)) AS activity_type,
    assigned_to_user AS assigned_user_id,
    deal_id,
    done AS is_done,
    due_to AS due_time
FROM {{ source('raw', 'activity') }}