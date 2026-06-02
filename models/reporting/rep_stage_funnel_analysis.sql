{{
    config(materialized='table')
}}

/*
    rep_stage_funnel_analysis
    ─────────────────────────
    Stage-level drop-off analysis with lost reason trends.
    Answers: "Where in the funnel are we losing the most customers, and why?"

    Grain: lost_month × final_stage_id × lost_reason_id.

    DUPLICATE ENTRY HANDLING:
    Deals marked as lost with reason "Duplicate Entry" are kept visible here
    for data quality monitoring, but are flagged separately via:
      - is_duplicate_entry:          true for these rows
      - deals_lost_excl_duplicates:  count excluding duplicate-entry losses

    ⚠️  IMPORTANT CAVEAT:
    We cannot verify whether "Duplicate Entry" was applied correctly without
    access to customer-level deal data (e.g., customer ID, email, or address).
    It is possible some deals are being marked as duplicates arbitrarily rather
    than because they genuinely represent the same customer.
    Recommendation: cross-reference with the deals table (if available) or
    request customer identifiers from source engineering to validate.

    Until verified, duplicate-entry losses should be excluded from:
      - Salesperson performance metrics (conversion_rate_pct)
      - Funnel drop-off rates used for strategy decisions
*/

with lost_deals as (
    select
        ds.deal_id,
        ds.final_stage_id,
        ds.final_stage_name,
        ds.lost_reason_id,
        ds.lost_reason_name,
        ds.lost_at,
        date_trunc('month', ds.lost_at)::date   as lost_month,
        ds.days_in_pipeline,
        ds.lost_reason_name = 'Duplicate Entry'  as is_duplicate_entry
    from {{ ref('int_deal_summary') }} ds
    where ds.is_lost = true
),

stage_reason_monthly as (
    select
        lost_month,
        final_stage_id,
        final_stage_name,
        lost_reason_id,
        lost_reason_name,
        is_duplicate_entry,
        count(*)                                            as deals_lost,
        count(*) filter (where not is_duplicate_entry)      as deals_lost_excl_duplicates,
        round(avg(days_in_pipeline), 1)                     as avg_days_to_loss
    from lost_deals
    group by
        lost_month,
        final_stage_id,
        final_stage_name,
        lost_reason_id,
        lost_reason_name,
        is_duplicate_entry
),

monthly_totals as (
    select
        lost_month,
        count(*)                                            as total_lost_this_month,
        count(*) filter (where not is_duplicate_entry)      as total_lost_excl_duplicates
    from lost_deals
    group by lost_month
)

select
    srm.lost_month,
    srm.final_stage_id,
    srm.final_stage_name,
    srm.lost_reason_id,
    srm.lost_reason_name,
    srm.is_duplicate_entry,
    srm.deals_lost,
    srm.deals_lost_excl_duplicates,
    srm.avg_days_to_loss,

    -- Share of ALL losses this month (including duplicates)
    round(
        100.0 * srm.deals_lost / nullif(mt.total_lost_this_month, 0),
        1
    )                                                       as pct_of_monthly_losses,

    -- Share excluding duplicate-entry losses (cleaner signal)
    round(
        100.0 * srm.deals_lost_excl_duplicates
            / nullif(mt.total_lost_excl_duplicates, 0),
        1
    )                                                       as pct_of_monthly_losses_excl_duplicates,

    -- Running cumulative losses per stage × reason (for trend charts)
    sum(srm.deals_lost) over (
        partition by srm.final_stage_id, srm.lost_reason_id
        order by srm.lost_month
        rows between unbounded preceding and current row
    )                                                       as cumulative_deals_lost

from stage_reason_monthly srm
inner join monthly_totals mt using (lost_month)
order by
    srm.lost_month,
    srm.deals_lost desc
