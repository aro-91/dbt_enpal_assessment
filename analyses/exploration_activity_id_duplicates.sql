/*
    activity_id is not a reliable key. 11 ids each show up twice (22 rows out of
    4,579; the other 4,557 ids appear once). The two rows under a repeated id are
    different activities (different deal, user, time, and often a different type),
    not accidental copies, so we keep them all. In real Pipedrive activity_id should be
    unique, so this is just how the sample data was built.

    Because of this, stg_pipedrive__activity tests activity_id for not_null only
    (not unique), and int_deal_sales_call builds its key from
    (deal_id, activity_type_code). That key stays unique for completed Sales Call
    1/2 activities: none of these repeated ids put two finished calls of the same
    type on the same deal.

    This query lists the repeated ids so you can see the two rows really do differ.
*/
with repeated_ids as (
    select activity_id
    from {{ source('pipedrive', 'activity') }}
    group by 1
    having count(*) > 1
)

select activity.*
from {{ source('pipedrive', 'activity') }} as activity
inner join repeated_ids
    on repeated_ids.activity_id = activity.activity_id
order by activity.activity_id, activity.deal_id
