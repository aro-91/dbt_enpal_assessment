/*
    Checks whether the two deal sources actually share deals. They mostly don't.
    The activity table and the deal_changes table cover almost completely
    different deals: of the 4,572 deals in activity, only 8 also show up in
    deal_changes (which has 1,995 deals). The id ranges overlap, but the actual
    ids don't match.

    Why it matters for rep_sales_funnel_monthly: the Sales Call steps (2.1/3.1,
    from activity) and the stage steps (1-9, from deal_changes) are basically two
    different sets of deals shown in one report. The report still does what the
    brief asks, but you can't read a call count against a stage count as if the
    same deals moved between them. See NOTES.md (Section 2).

    This is almost certainly just how the sample data was built; the two tables
    look like they were generated with separate deal ids.
*/
with deal_changes_deals as (
    select distinct deal_id from {{ source('pipedrive', 'deal_changes') }}
)

, activity_deals as (
    select distinct deal_id from {{ source('pipedrive', 'activity') }}
)

select
    (select count(*) from deal_changes_deals) as deal_changes_deals
    , (select count(*) from activity_deals) as activity_deals
    , (
        select count(*) from activity_deals
        where deal_id in (select deal_id from deal_changes_deals)
    ) as deals_in_both
