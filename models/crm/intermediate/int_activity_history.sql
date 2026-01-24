{{ 
config(
    materialized='incremental',
    unique_key='activity_id',
    incremental_strategy='merge'
) 
}}

{% set threshold_days = 15 %}  -- must be adjusted according to business pace and needs

SELECT
    activity_id
    , assigned_user_id
    , deal_id
    , is_done
    , due_to_at
    , activity_type
FROM {{ ref('stg_pipedrive_activity') }}
{% if is_incremental() %}
    -- process only recent activities to reduce volume
    WHERE due_to_at >= current_date - interval '{{ threshold_days }} day'
{% endif %}
