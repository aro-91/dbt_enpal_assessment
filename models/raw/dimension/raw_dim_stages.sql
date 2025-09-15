-- Raw model for stages
-- Loads stages data

{% set source_data = source('postgres_public', 'stages') %}

select
    stage_id,
    stage_name,
    current_date as load_date
from {{source_data}}