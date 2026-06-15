/*
    Checks that the user references actually point at real users. They do, every
    user_id in deal_changes and every assigned_to_user in activity exists in the
    users table (0 missing). This is worth noting because the deal_id link
    between activity and deal_changes does not line up (see
    exploration_activity_deal_changes_overlap.sql). So the broken link is
    specific to deal_id, not the data in general. The users table itself is clean
    too: 1,787 rows, no repeated ids.
*/
with deal_change_users as (
    select distinct cast(new_value as integer) as user_id
    from {{ source('pipedrive', 'deal_changes') }}
    where changed_field_key = 'user_id'
)

, activity_users as (
    select distinct assigned_to_user as user_id
    from {{ source('pipedrive', 'activity') }}
)

select
    'deal_changes.user_id' as source_field
    , count(*) as referenced_users
    , count(*) filter (where users.id is null) as missing_from_users
from deal_change_users
left join {{ source('pipedrive', 'users') }} as users
    on deal_change_users.user_id = users.id

union all

select
    'activity.assigned_to_user' as source_field
    , count(*) as referenced_users
    , count(*) filter (where users.id is null) as missing_from_users
from activity_users
left join {{ source('pipedrive', 'users') }} as users
    on activity_users.user_id = users.id
