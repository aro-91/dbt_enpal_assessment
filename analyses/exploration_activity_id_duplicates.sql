/*
    Exploratory query: activity_id is not unique in the raw `activity` table
    (11 duplicate ids across 4,579 rows). This is why
    stg_pipedrive__activity does not carry a `unique` test on activity_id
    (just not_null), and int_deal_sales_call derives its primary key
    (deal_sales_call_sk) from (deal_id, activity_type_code) instead.
*/
select
    count(*) as total_rows
    , count(distinct activity_id) as distinct_activity_ids
    , count(*) - count(distinct activity_id) as duplicate_count
from {{ source('pipedrive', 'activity') }}
