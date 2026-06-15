/*
    There is no `deals` table in the raw data; deal_changes is the only record
    of deal history. This backs up the row counts in NOTES.md (Section 2):
    - stage_id: stage changes (8,906 rows / 1,995 deals, 1 to 10 per deal)
    - user_id: owner changes (2,500 rows / 1,995 deals)
    - add_time / lost_reason: about one per deal (2,000 rows / 1,995 deals each;
      see exploration_lost_reason_distribution.sql for the 5 deals with a second
      one)
*/
select
    changed_field_key
    , count(*) as change_count
    , count(distinct deal_id) as distinct_deals
from {{ source('pipedrive', 'deal_changes') }}
group by 1
order by 2 desc
