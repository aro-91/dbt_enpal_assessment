-- Identify which 'type' codes correspond to 'Sales Call 1' and 'Sales Call 2'

select 
    t.name as activity_name,
    t.type as activity_type_code,
    count(a.activity_id) as volume
from {{ source('postgres_public', 'activity_types') }} t
left join {{ source('postgres_public', 'activity') }} a 
    on t.type = a.type
group by 1, 2
order by 3 desc