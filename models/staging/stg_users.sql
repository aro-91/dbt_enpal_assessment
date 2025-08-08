-- This staging model cleans up and standardizes the public.users table.
-- It renames columns for clarity and consistency.
SELECT
    id AS user_id,
    "name" AS user_name,
    email AS user_email,
    modified AS updated_date
FROM {{ source('raw', 'users') }}