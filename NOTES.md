# Enpal Analytics Engineer Take-Home: Project Walkthrough

This walks through how I built the project: what I looked at in the data, how I modeled
it, why I made each call, and what the numbers show. The queries behind the findings are
in `analyses/`.

## 1. Objective

Build `rep_sales_funnel_monthly`, a monthly sales funnel report over Pipedrive CRM data,
covering:

- Steps 1 to 9: Lead Generation, Qualified Lead, Needs Assessment, Proposal/Quote
  Preparation, Negotiation, Closing, Implementation/Onboarding, Follow-up/Customer
  Success, Renewal/Expansion.
- Sub-steps 2.1 (Sales Call 1) and 3.1 (Sales Call 2).

Output columns: `month`, `kpi_name`, `funnel_step`, `deals_count`.

The brief also asks for a deep understanding of the Pipedrive source data, dbt `sources`,
and a layered model "for optimal relevance and maintainability."

## 2. Source Data: What's Actually There

6 raw tables, loaded by `docker-compose` and `init.sql`:

| Table | Rows | What it is |
|---|---|---|
| `activity` | 4,579 | Calls/meetings tied to deals (`done` flag, `due_to` date) |
| `activity_types` | 4 | Lookup: `meeting` = "Sales Call 1", `sc_2` = "Sales Call 2", plus 2 others we don't need |
| `deal_changes` | 15,406 | A change log, and the only record of deal history |
| `fields` | 4 | Details about each field, plus the labels behind option codes |
| `stages` | 9 | Pipeline stages, one for each funnel step 1 to 9 |
| `users` | 1,787 | Sales reps / deal owners |

**The main thing to know:** there is no `deals` table. Everything about a deal (when it
was created, its owner, its stage, its lost reason) is just a row in `deal_changes`, with
one row per change (`deal_id`, `change_time`, `changed_field_key`, `new_value`). Across
all of those changes there are **1,995 different deals**
(`analyses/exploration_deal_changes_field_breakdown.sql`).

Findings that shaped the model, each with a query in `analyses/` to back it up:

1. **Deals don't move through the stages in order, and they skip stages.** A deal can jump
   forward (2 to 5) or drop back (8 to 1). 2,510 of the 8,906 stage changes are jumps like
   that, and **84% of deals reach a stage without a record of every stage before it**
   (`analyses/exploration_stage_skipping.sql`). This drives the main decision in
   Section 4a: how to count a step when stages get skipped.
2. **`lost_reason` is filled in for nearly every deal** (5 reasons, roughly 380 to 425
   deals each, spread evenly). That spread looks like filler data rather than a real "this
   deal was lost" signal, so I treat it as just an attribute and do **not** use it to drop
   deals from the funnel. The same query shows 5 deals with a second `add_time`/`lost_reason`
   row, which the funnel model doesn't use, so it does no harm
   (`analyses/exploration_lost_reason_distribution.sql`).
3. **About half of all activities are not done yet.** For both `meeting` and `sc_2`, roughly
   50% are scheduled but not completed
   (`analyses/exploration_activity_done_split.sql`).
4. **`activity_id` is not unique:** 11 ids each appear twice, and the two rows under a
   repeated id are different activities (different deal, time, often type), not copies
   (`analyses/exploration_activity_id_duplicates.sql`). So I keep all the rows and just
   don't use `activity_id` as a key (see Section 6).
5. **`activity` and `deal_changes` are about almost completely different deals.** Of the
   4,572 deals in `activity`, only **8** also show up in `deal_changes` (which holds 1,995
   deals) (`analyses/exploration_activity_deal_changes_overlap.sql`). This is the biggest
   thing to flag: the Sales Call steps (2.1/3.1, from `activity`) and the stage steps (1-9,
   from `deal_changes`) are really two different sets of deals shown in one report. The
   model still does what the brief asks, but you can't read a call count against a stage
   count as if the same deals flowed between them (see Section 5). This is almost certainly
   just how the sample data was built; in real Pipedrive, `activity.deal_id` would point
   back to the deal.
6. **The two tables cover different date ranges.** Stage changes run from 2024-01 to
   2025-02, but activities stop at 2024-09-13
   (`analyses/exploration_time_coverage.sql`), so months after September 2024 have stage
   steps but no Sales Call rows. The stage values themselves are clean whole numbers 1 to 9
   with nothing odd in them (`analyses/exploration_stage_value_validity.sql`).
7. **The two tables the report doesn't use (`users` and `fields`) are fine.** `users` is
   clean (1,787 rows, no repeated ids), and every `user_id` in `deal_changes` and every
   `assigned_to_user` in `activity` points at a real user
   (`analyses/exploration_user_references.sql`). So the broken `deal_id` link in finding 5
   is specific to those two tables, not the data in general. `fields` just holds the labels
   behind the codes (`analyses/exploration_fields_decodes.sql`): it spells out
   `lost_reason` (1 = Customer Not Ready, and so on) and `stage_id` (matching the stages
   table). All six raw tables have now been looked at; `activity_types` is a 4-row lookup
   that's documented in the sources file and used directly by the Sales Call model.

## 3. Architecture

```
sources (raw Postgres tables)
   |
   v
staging/pipedrive/            views: renamed and retyped, one row in for one row out
   stg_pipedrive__activity
   stg_pipedrive__activity_types
   stg_pipedrive__deal_changes
   stg_pipedrive__stages
   |
   v
intermediate/                 the real logic (one row per deal+stage / per completed call)
   int_deal_stage_history      one row per deal per stage entered (gaps filled in)
   int_deal_sales_call         completed Sales Call 1/2 activities
   |
   v
marts/reporting/
   rep_sales_funnel_monthly    the final report
```

Each `int_` model has its own unique key (`deal_stage_sk`, `deal_sales_call_sk`), built
with `dbt_utils.generate_surrogate_key` and checked with `unique` and `not_null` tests.
That gives each model a reliable key without leaning on `activity_id`, which isn't unique
(see Section 6).

`users` and `fields` are written up as sources so the whole schema is documented, but they
don't have models. The report doesn't need them, so I didn't build models just in case.

## 4. Key Design Decisions

### a) Counting a deal into every stage it reached (Steps 1 to 9, the Pipedrive way)

This is the most important call in the project. Because 84% of deals skip at least one
stage, the count at each step depends entirely on what you do with the skipped ones. Two
reasonable options:

- **Only count what was logged:** count a deal at a stage only if it actually logged a move
  to that stage. True to the raw data, but it undercounts: a deal that jumps from 2 to 5
  never shows up at stages 3 and 4.
- **Fill in the gaps (what I chose):** a deal that reached stage N counts at every stage 1
  through N. This matches **Pipedrive's own deal progress report**, which says: "The
  entered stage deal count also includes deals that have skipped that stage while moving on
  to a future stage. For example, if a deal has moved from stage two directly to stage five
  in the time frame selected, it will show as having entered stages three, four and five"
  ([Pipedrive: Insights reports - deal progress](https://support.pipedrive.com/en/article/insights-reports-deal-progress)).

I went with filling in the gaps so the report means the same thing the sales team already
sees in Pipedrive. The difference is big: stage 5 is 894 deals if you only count what was
logged, versus **1,693** once you fill the gaps. I count a deal as entering a stage at the
first time it reached that stage or any later one (the earliest `change_time` among its
events at that stage or beyond), so a skipped stage is dated to the jump that took the deal
past it. The result is a funnel where each step is smaller than the one before, the way
you'd expect.

**Why we have to fill the gaps ourselves (the data doesn't already do it).** Pipedrive
works this out when it draws the report; it never saves those extra rows back into the
data. When a rep drags a deal forward, Pipedrive stores one "now at stage N" row, not one
row for each stage in between. Take deal `680288`: the raw `deal_changes` data has exactly
two stage rows (stage 1, then stage 9), yet Pipedrive's report shows it in all nine stages.
Our model turns those two rows back into nine. Rebuilding that report logic from the raw
events is the actual job; if the raw data already had the filled-in rows, there'd be
nothing to build.

### b) Sales Calls (Steps 2.1 / 3.1) count completed activities only

About half of `meeting`/`sc_2` activities are not done (scheduled but not completed).
Instead of guessing, I checked how Pipedrive itself handles this: its "marked as done"
logic and its activity reports both count only `done = true` activities as completed
([source](https://support.pipedrive.com/en/article/activity-marked-as-done-logic),
[source](https://support.pipedrive.com/en/article/insights-reports-activities-performance)).
That also lines up with (a): both are about the deal actually reaching a step, not just
having something booked.

### c) `funnel_step` stored as `numeric(3,1)`

It holds `1, 2, 2.1, 3, 3.1, 4 ... 9`, which sorts in the right order in any BI tool on its
own, and matches the brief's "Step 2.1 / 3.1" numbering directly.

### d) `kpi_name` uses the stage name straight from the source

For example "Qualified lead" (lowercase, exactly as it sits in the `stages` table) instead
of re-spelling it as "Qualified Lead". That keeps the labels matching what's in the CRM.
(The `fields` lookup actually stores the title-case version, "Qualified Lead", so the two
sources disagree on capitalization; I went with the `stages` table.) Worth a quick mention
in a walkthrough: easy to tidy the capitalization if the BI team wants it consistent.

### e) Every month shows every step (0 where nothing happened)

A plain `group by` only gives you a row where something happened, so some months would be
missing steps. To make the report easy to chart, I add a month spine
(`dbt_utils.date_spine`) and fill the gaps with 0. The one catch is the difference between
"zero happened" and "no data": the activity table stops in September 2024, so I fill the
stage steps across the whole stage range but the Sales Call steps only across the months
that actually have activity. That way you never see a made-up "0 calls" for a month where
there simply isn't any call data.

## 5. Result and Initial Insights

`dbt build` produces 1 table, 6 views, and **42 passing tests**. Totals across all months
(2024-01 to 2025-02), using the gap-filling approach from Section 4a:

The stage steps (1-9) and the Sales Call steps (2.1/3.1) sit in the same table but come
from different sources and, per finding 5 in Section 2, almost completely different deals.
So the conversion column only makes sense down the stage rows. The call rows show their own
deal counts, not a conversion from the step above.

| Step | KPI | Deals entered | Conversion (stage rows only) |
|---|---|---:|---:|
| 1 | Lead Generation | 1,995 | 100% of all deals |
| 2 | Qualified lead | 1,990 | 99.7% |
| 2.1 | Sales Call 1 | 568 | n/a (different deals) |
| 3 | Needs Assessment | 1,951 | 98.0% |
| 3.1 | Sales Call 2 | 560 | n/a (different deals) |
| 4 | Proposal/Quote Preparation | 1,862 | 95.4% |
| 5 | Negotiation | 1,693 | 90.9% |
| 6 | Closing | 1,424 | 84.1% |
| 7 | Implementation/Onboarding | 1,081 | 75.9% |
| 8 | Follow-up/Customer Success | 723 | 66.9% |
| 9 | Renewal/Expansion | 324 | 44.8% |

**What stands out:**

- The step 1 total (1,995) matches the total number of deals exactly, and each stage is
  smaller than the last. That tells me no deals are dropped and the gap-filling holds
  together.
- The top of the funnel is healthy (about 95 to 99% carry through to Proposal). The real
  drop-off is later on: Closing to Onboarding (76%), Onboarding to Follow-up (67%), and the
  steepest, Follow-up to Renewal/Expansion (45%). Deals are lost in delivery and renewal,
  not in qualifying.
- The Sales Call counts (568 and 560) are not a conversion from the stages above them. They
  come from different deals (finding 5). On their own, the `activity` data shows about half
  of all logged Sales Calls are marked done. Whether the two tables should join at all is
  the first question I'd raise with whoever owns the data.

## 6. Data Quality and Testing

42 tests across all layers:

- `not_null` and `unique` on the real keys (`stage_id`, `activity_type_code`, and so on)
  and on the generated keys (`deal_stage_sk`, `deal_sales_call_sk`) on the intermediate
  models.
- `accepted_values` on the fixed-value columns (`changed_field_key`, `activity_type_code`,
  `kpi_name`, `funnel_step`). These also act as documentation of what values are allowed.
- `dbt_utils.unique_combination_of_columns` on `(month, funnel_step)`, which guarantees one
  row per funnel step per month.

The generated keys use `dbt_utils.generate_surrogate_key` (it works across databases and
handles nulls) instead of writing the hash by hand.

**One known data issue:** `activity.activity_id` repeats for 11 ids (each twice), and those
pairs are different activities rather than duplicate rows, so I keep them all and test
`activity_id` for `not_null` only, not `unique` (noted in the column description).
`int_deal_sales_call` keys on `(deal_id, activity_type_code)` instead, which is unique for
completed Sales Call 1/2 activities.

## 7. SQL Efficiency Notes

- Staging and intermediate are views: they cost no storage, always show the latest data,
  and Postgres folds them into the final query anyway.
- Only the final report is built as a table, since that's the one BI tools hit over and
  over.
- `rep_sales_funnel_monthly` counts `deal_changes` and `activity` once each, builds a
  month-by-step grid from the date spine, and joins the counts onto it (filling gaps with
  0). Each source is still read once, not once per step.
- `int_deal_stage_history` boils `deal_changes` down to one row per deal and stage before
  it joins to `stages`, so the join is against a 9-row table and stays cheap.
- Nothing here is tied to Postgres beyond `date_trunc` and a cast, so it would move to
  Snowflake (Enpal's warehouse) with little change.

## 8. What I'd Add Next

- A `dim_deal` model (one row per deal) as a base others could reuse, pulling `deal_changes`
  into one row per deal with its current stage, owner, created date, and lost reason. I kept
  this project scoped to the brief, but `dim_deal` is the obvious next model: it would let
  both intermediate models join to deal details and let you break the funnel down by owner,
  by sign-up month, or by lost reason.
- Bring in `users` for a per-rep or per-owner view of the funnel.
- Add conversion-rate columns straight in the report (or a model after it) instead of
  working them out by hand.
- If `deal_changes` gets large, switch `int_deal_stage_history` to an incremental model
  that reprocesses each deal that gets a new event (not just new `change_time` rows, since
  the back-fill means one new event can change several stages for a deal), so full
  rebuilds aren't needed.
