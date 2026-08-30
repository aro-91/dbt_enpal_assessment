-- =====================================================================
/*
This data assessment focuses on the table provided in the source and includes basic checks for data quality, integrity and completeness. The goal is to understand the structure and content of the data and identify any potential issues.

For the overall approach, business context, and conclusions drawn from these findings, see findings_and_approach.md.
*/
-- =====================================================================


-- =====================================================================
-- activity_types
-- =====================================================================
SELECT * FROM activity_types;

SELECT COUNT(*) AS row_count
     , COUNT(*) FILTER (WHERE name IS NULL)   AS null_name
     , COUNT(*) FILTER (WHERE active IS NULL) AS null_active
     , COUNT(*) FILTER (WHERE type IS NULL)   AS null_type
     , COUNT(DISTINCT id) AS distinct_id
FROM activity_types;

SELECT active, COUNT(*) FROM activity_types GROUP BY active ORDER BY 1;

SELECT type, COUNT(*) FROM activity_types GROUP BY type ORDER BY 2 DESC;

/*
Context Conclusion:
Tiny lookup table: 4 rows describing activity types (all calls, 3 active, 1 inactive) configured in Pipedrive.

Technical assessment:
No technical issues, asiode from type desccription being inconsistent (meeting vs. sc_2)

*/

-- =====================================================================
-- activity
-- =====================================================================
SELECT * FROM activity;

SELECT COUNT(*) AS row_count
     , COUNT(DISTINCT activity_id) AS distinct_activity_id
     , COUNT(*) FILTER (WHERE activity_id IS NULL)      AS null_activity_id
     , COUNT(*) FILTER (WHERE type IS NULL)              AS null_type
     , COUNT(*) FILTER (WHERE assigned_to_user IS NULL)  AS null_assigned_to_user
     , COUNT(*) FILTER (WHERE deal_id IS NULL)           AS null_deal_id
     , COUNT(*) FILTER (WHERE done IS NULL)               AS null_done
     , COUNT(*) FILTER (WHERE due_to IS NULL)             AS null_due_to
     , MIN(due_to) AS min_due_to
     , MAX(due_to) AS max_due_to
FROM activity;

SELECT done, COUNT(*) FROM activity GROUP BY done ORDER BY 1;

SELECT type, COUNT(*) FROM activity GROUP BY type ORDER BY 2 DESC;

SELECT EXTRACT('month' FROM due_to) as month,  type, COUNT(*) FROM activity GROUP BY month, type ORDER BY 1,2 DESC;

-- activity_id not unqiue
SELECT activity_id, COUNT(*)
FROM activity
GROUP BY activity_id
HAVING COUNT(*) > 1
ORDER BY 2 DESC;

-- examples showing activity_id duplicates
SELECT *
FROM activity
WHERE activity_id IN (
 521731
, 332746	
, 283914	
, 370773	
, 818588	
, 855539	
, 206894	
, 835226	
, 488221	
, 283308	
, 500358
)
ORDER BY activity_id;

-- Referential integrity vs. dimension tables.
SELECT COUNT(*) AS orphan_type_rows
FROM activity a LEFT JOIN activity_types t ON a.type = t.type
WHERE a.type IS NOT NULL AND t.type IS NULL;

SELECT COUNT(*) AS orphan_user_rows
FROM activity a LEFT JOIN users u ON a.assigned_to_user = u.id
WHERE a.assigned_to_user IS NOT NULL AND u.id IS NULL;

/*
Context Conclusion:
Activity log table listing all open activities per deal including it's due date. 


Technical assessment:
activity_id not unique for 11 records. Is an edge case at 0.24%, but doesn't show pattern to be addressed in the model and needs to be fixed in the source. 
due_to spans 2024-01-01 to 2024-09-13.
Done satus about 50/50, types are split evenly across the 4 types including the "inactive" type.
-> Classic hallmarks of a synthetic dataset, but no issues with the data itself.

*/

-- =====================================================================
-- deal_changes
-- =====================================================================
SELECT * FROM deal_changes;

SELECT COUNT(*) AS row_count
     , COUNT(DISTINCT deal_id) AS distinct_deal_id
     , COUNT(*) FILTER (WHERE deal_id IS NULL)           AS null_deal_id
     , COUNT(*) FILTER (WHERE change_time IS NULL)        AS null_change_time
     , COUNT(*) FILTER (WHERE changed_field_key IS NULL)  AS null_changed_field_key
     , COUNT(*) FILTER (WHERE new_value IS NULL)          AS null_new_value
     , MIN(change_time) AS min_change_time
     , MAX(change_time) AS max_change_time
     , COUNT(DISTINCT changed_field_key) AS distinct_field_keys
FROM deal_changes;

-- Change types sanity check
SELECT changed_field_key, COUNT(*)
FROM deal_changes
GROUP BY changed_field_key
ORDER BY 2 DESC;

-- Funnelstages sanity check
select new_value as stage_id, count(distinct deal_id)
from deal_changes where changed_field_key = 'stage_id'
group by 1 order by 1;

-- Stage re-entry: deals that hit the same stage_id more than once
select deal_id, new_value, count(*)
from deal_changes where changed_field_key = 'stage_id'
group by 1,2 having count(*) > 1
order bY 1;


-- 5 Deals with 2 add_time_events
select deal_id, count(*) as add_time_events
from deal_changes
where changed_field_key = 'add_time'
group by deal_id
having count(*) > 1
order by deal_id;

-- Referential integrity: every changed_field_key should exist in fields.field_key.
SELECT COUNT(*) AS orphan_field_key_rows
FROM deal_changes d LEFT JOIN fields f ON d.changed_field_key = f.field_key
WHERE f.field_key IS NULL;

-- Referential integrity: stage_id changes should resolve to a real stage.
SELECT COUNT(*) AS orphan_stage_changes
FROM deal_changes d LEFT JOIN stages s ON d.new_value = s.stage_id::text
WHERE d.changed_field_key = 'stage_id' AND s.stage_id IS NULL;

-- Referential integrity: user_id changes should resolve to a real user.
SELECT COUNT(*) AS orphan_deal_changes_user
FROM deal_changes d LEFT JOIN users u ON d.new_value = u.id::text
WHERE d.changed_field_key = 'user_id' AND u.id IS NULL;


/*

Context Conclusion:
Log table tracking field changes for deals. This will be our main table to map deal ids to corresponding stages with their timestamps. 
IMPORTANT: deals can move freely between stages, not only forward, meaning that a deal can re-enter a stage multiple times. This is by design according to Pipedrive (https://www.pipedrive.com/en/blog/sales-pipeline-management)
Our dataset doesn't confirm this behaviour - our deals only move forward - , but it will be important for our design approach.


Technical assessment:
add_time represents the creation date of the deal (https://devcommunity.pipedrive.com/t/pipedrive-deal-missing-add-time/7295) and should be used as basis for cohorting the deals. 
When checking direction of deal movements, discovered that 5 deals have multiple add_time events and 2 distinct timestamps, which is impossible for a real deal. Likely caused by the synthetic dataset but can be easily tested for.
change_time spans 2024-01-01 to 2025-03-11, longer than activities, which means we will have deals without any activities between 2024-10-28 and 2025-03-11. This is not an issue for the funnel model, but should be considered when building other models that require activities to be present for a deal.

*/

-- =====================================================================
-- fields
-- =====================================================================
SELECT * FROM fields;

select
    f.field_key
    , f.name        as field_name
    , opt ->> 'id'      as option_id
    , opt ->> 'label'   as option_label

from fields as f
cross join jsonb_array_elements(f.field_value_options) as opt

where f.field_value_options is not null

order by f.field_key, (opt ->> 'id')::int;

/*
Context Conclusion:
Metadata for four crm field including picklist items for lost reason and funnel stage. 
This seems useful, but only includes deal stages, not the activties.

Technical assessment:
Metadata table with 4 rows.
Picklist items are stored in field_value_options as json and need to be unpacked to be used as reference table.

*/

-- =====================================================================
-- stages
-- =====================================================================
SELECT * FROM stages ORDER BY stage_id;


/*
Context Conclusion:
Includes funnel stages for 9 funnel steps. Missing the activities.
Seems redunant when using fields.field_value_options for stage_id. When analysis on other fields is required, likely to be the case for reason_lost, a general metadata table like fields is more useful.

Technical assessment:
Stage 2 Qualified Lead is misspelled as "Qualified lead" (lowercase "lead"). This could have several reasons, but confirms the decision to use the fields table also from a technical perspective.

*/

-- =====================================================================
-- users
-- =====================================================================
SELECT * FROM users;

SELECT COUNT(*) AS row_count
     , COUNT(DISTINCT id)    AS distinct_id
     , COUNT(DISTINCT email) AS distinct_email
     , COUNT(*) FILTER (WHERE name IS NULL)     AS null_name
     , COUNT(*) FILTER (WHERE email IS NULL)    AS null_email
     , COUNT(*) FILTER (WHERE modified IS NULL) AS null_modified
     , MIN(modified) AS min_modified
     , MAX(modified) AS max_modified
FROM users;

SELECT email, COUNT(*) FROM users GROUP BY email HAVING COUNT(*) > 1;

/*
Context Conclusion:
Includes Pipedrive system users, not all contacts.
Not relevant for our use case, so will be omitted.

Technical assessment:
While id is unique, email is not. Pipedrive docs not clear if this is a requirement or not.

*/

-- =====================================================================
-- combined: does a sales call gate progression to the next stage?
-- =====================================================================

-- only 8 deal_ids overlap in both sets
select a.deal_id
from activity a
where a.deal_id in (select distinct deal_id from deal_changes)
group by a.deal_id
order by a.deal_id;


-- Even for the 8 instance, the Sales calls are not a prerequisite to reaching the next deal stage
with overlap_deals as (
    select a.deal_id
    from activity a
    where a.deal_id in (select distinct deal_id from deal_changes)
    group by a.deal_id
),
stage3_entry as (
    select deal_id, reached_at
    from public_pipedrive_analytics.trns_deal_stages_backfill
    where stage_id = 3
),
stage4_entry as (
    select deal_id, reached_at
    from public_pipedrive_analytics.trns_deal_stages_backfill
    where stage_id = 4
),
calls as (
    select
        a.deal_id
        , at.activity_type_name
        , a.due_at
        , a.is_done
    from public_pipedrive_staging.stg_pipedrive__activities a
    join public_pipedrive_staging.stg_pipedrive__activity_types at
        on a.activity_type_code = at.activity_type_code
    where at.activity_type_name in ('Sales Call 1', 'Sales Call 2')
)
select
    d.deal_id
    , s3.reached_at        as stage3_reached_at
    , s4.reached_at        as stage4_reached_at
    , c.activity_type_name
    , c.due_at             as call_due_at
    , c.is_done
from overlap_deals d
left join stage3_entry s3 on d.deal_id = s3.deal_id
left join stage4_entry s4 on d.deal_id = s4.deal_id
left join calls c on d.deal_id = c.deal_id
order by d.deal_id, c.activity_type_name, c.due_at;


-- See findings_and_approach.md for the overall conclusions, business context, and future recommendations drawn from all the findings above.