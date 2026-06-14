/*
    Exploratory query: there is no `deals` table in the raw data - deal_changes
    is the only source of deal history. This confirms the row counts behind the
    source-data findings in NOTES.md (Section 3):
    - stage_id: pipeline stage history (8,906 rows / 1,995 deals, 1-10 events per deal)
    - user_id: deal owner (re)assignment history (2,500 rows / 1,995 deals)
    - add_time / lost_reason: ~one entry per deal (2,000 rows / 1,995 distinct deals
      each - see exploration_lost_reason_distribution.sql for the 5 deals with a
      second entry)
*/
select
    changed_field_key
    , count(*) as change_count
    , count(distinct deal_id) as distinct_deals
from {{ source('pipedrive', 'deal_changes') }}
group by 1
order by 2 desc
