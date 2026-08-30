{#
    Purpose: Flattens the two sales activities (Sales Call 1 and Sales Call
    2) per deal with their first due date.

    Grain: one row per deal_id and activity_type_name.

    Possible improvement: substitute due_at with the actual activity
    timestamp once available in source.
#}

with stg_pipedrive__activities as (

    select * from {{ ref('stg_pipedrive__activities') }}

),

stg_pipedrive__activity_types as (

    select * from {{ ref('stg_pipedrive__activity_types') }}

),

calls as (
    {# join activities to activity_types on the shared type text code,
       filtered to completed Sales Call 1/2 activities only #}

    select
        activities.deal_id
        , activity_types.activity_type_name
        , activities.due_at

    from stg_pipedrive__activities as activities
    inner join stg_pipedrive__activity_types as activity_types
        on activities.activity_type_code = activity_types.activity_type_code
    where activity_types.activity_type_name in ('Sales Call 1', 'Sales Call 2')
      and activities.is_done = true

),

first_completed as (
    {# selects the first due_at per deal_id and activity_type #}

    {{ first_event_by_grain('calls', 'deal_id, activity_type_name', 'due_at') }}

),

final as (
    {# due_at is used as a completion-timestamp proxy; should use
       is_done combined with updated_since once available #}

    select
        deal_id
        , activity_type_name
        , due_at    as completed_at

    from first_completed

)

select * from final
