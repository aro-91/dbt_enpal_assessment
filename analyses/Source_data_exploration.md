# Exploratory Analysis

The below analysis has been done on the raw data to understand it better and do some basic checks

---

### 1. `activity`

This table contains information on individual activities. The primary goal is to validate the uniqueness of `activity_id` and understand the distribution of activities.

```sql
-- Count total records and check for a duplicate primary key (activity_id)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT activity_id) AS unique_activity_ids
FROM public.activity;

-- Check for the specific issue with duplicate activity_id you found
SELECT
    activity_id,
    COUNT(*) AS records_count
FROM public.activity
GROUP BY 1
HAVING COUNT(*) > 1;
---------------------
Activity Id | Count |
---------------------
521731	    |   2   |
332746	    |  	2   |
283914	    |  	2   |
370773	    |  	2   |
818588	    |  	2   |
855539	    |  	2   |
206894	    |  	2   |
835226	    |  	2   |
488221	    |  	2   |
283308	    |  	2   |
500358	    |  	2   |
---------------------

-- Analyze the distribution of activities by their type
SELECT
    "type" AS activity_type_id,
    COUNT(*) AS activity_count
FROM public.activity
GROUP BY 1;

-- Find the distribution of completed (done) vs. scheduled activities
SELECT
    done,
    COUNT(*) AS records_count
FROM public.activity
GROUP BY 1;
```
Findings

There are 11 total duplicate activity id 
found in the table. Ideally it shouldnt happen based 
on my CRM pipedrive research . However for now i didnt 
enforce strict unique key testing since there is no analysis
done by joining activity id
(In future if needed we can create a combined key with activity type and deal
to ensure uniqueness in case if the business confirms there are 
acceptable)

The done column grouping gives the idea that half of the 
activities are not completed. However since our expected 
report doesnt need any further analysis on that level, i have 
ignored that part

### 2. `activity types`

```sql
SELECT
    COUNT(*) AS total_activity_types,
    COUNT(CASE WHEN active = 'Yes' THEN 1 END) AS active_types,
    COUNT(CASE WHEN active = 'No' THEN 1 END) AS inactive_types
FROM public.activity_types;

-- View all activity type names
SELECT
    "name",
    active
FROM public.activity_types
ORDER BY active DESC, "name" ASC
```
Findings

Activity type "Follow Up Call" is not active. However it is not filtered
since we didnt have any requirement for that. I wanted to keep
stage layer with almost all data so it can easily accommodate future requirement.

### 3. `deal_changes`

```sql
-- Count total changes and check for common changed fields
SELECT
    COUNT(*) AS total_changes,
    COUNT(DISTINCT deal_id) AS unique_deals_with_changes,
    COUNT(DISTINCT changed_field_key) AS unique_fields_changed
FROM public.deal_changes;

-- Find the most frequently changed fields
SELECT
    changed_field_key,
    COUNT(*) AS times_changed
FROM public.deal_changes
GROUP BY 1
ORDER BY 2 desc;
```

Findings

There are total 1995 distinct deals and 15k changes
with stage changes sharing most percentage with 8k records

### 4.Fields

```sql
-- Find fields that have pre-defined options
SELECT
    "name",
    field_key,
    field_value_options
FROM public.fields
WHERE field_value_options IS NOT NULL;
```

Findings 
I compared the stage values with possible field options for stage.
It matches perfectly. However since we have stage info, i am not using 
field table

### 5.Stages
```sql
-- Check the total number of stages and their names
SELECT
    COUNT(*) AS total_stages
FROM public.stages;

-- List all stages in order to understand the funnel path
SELECT
    stage_id,
    stage_name
FROM public.stages
ORDER BY stage_id;
```
Findings

Stage master data is simple. And it matched field options

### 6.Users

```sql
-- Count total users and check for null emails
SELECT
    COUNT(*) AS total_users,
    COUNT(CASE WHEN email IS NULL THEN 1 END) AS users_with_no_email
FROM public.users;

-- Find the top users by their last modified date (as an indicator of activity)
SELECT
    "name",
    modified
FROM public.users
ORDER BY modified DESC
```

Findings

The User table master has email updated for many users.
We dont need a snapshot to track the changes since it has 
modified date in it . However our final report data doesnt 
need any user related dimensional analysis and hence just
created stage only

