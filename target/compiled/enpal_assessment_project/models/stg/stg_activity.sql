

with done_activities as (
select
    activity_id,
    deal_id,
    assigned_to_user,
    type,
    due_to::timestamp as due_date,
    done
from "postgres"."public"."activity"
where done is true
),

deduped as (
select *,
    row_number() over (partition by activity_id order by due_date desc) as rn
from done_activities
)

select
    activity_id,
    deal_id,
    assigned_to_user,
    type,
    due_date,
    done
from deduped
where rn = 1