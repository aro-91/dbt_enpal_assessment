-- Raw model for Activity type
-- Loads activity type data

{% set source_data = source('postgres_public', 'activity_types') %}

select
    id,
    name,
    active,
    type,
    current_date as load_date
from {{source_data}}