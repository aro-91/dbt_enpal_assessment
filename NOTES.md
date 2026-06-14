# Enpal Analytics Engineer Take-Home: Project Walkthrough

This document records the approach and reasoning behind the project: what was explored,
how it was modeled, why each decision was made, and what the output shows. The runnable
exploration queries behind the findings live in `analyses/`.

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

## 2. How This Maps to the Assessment Criteria

| Criterion | Where it's demonstrated |
|---|---|
| **Exploratory Analysis** | Section 3 plus 5 runnable queries in `analyses/*.sql` (one per finding) |
| **Data Modeling** | Section 4 (architecture) and Section 5 (design decisions): sources, staging, intermediate, marts, surrogate keys, 42 tests |
| **SQL Code Efficiency** | Section 8: materialization strategy, single `union all` plus `group by`, pre-aggregation before joins |
| **Project Organization & Clarity** | This doc, the README, per-layer `_*.yml` docs/tests, and this table |

## 3. Source Data: What's Actually There

6 raw tables, loaded via `docker-compose` and `init.sql`:

| Table | Rows | Role |
|---|---|---|
| `activity` | 4,579 | Calls/meetings linked to deals (`done` flag, `due_to` date) |
| `activity_types` | 4 | Lookup: `meeting` = "Sales Call 1", `sc_2` = "Sales Call 2", plus 2 others not in scope |
| `deal_changes` | 15,406 | Change log, the only source of deal history |
| `fields` | 4 | Field metadata / enum option labels |
| `stages` | 9 | Pipeline stages, 1:1 with funnel steps 1 to 9 |
| `users` | 1,787 | Sales reps / deal owners |

**The key discovery:** there is no `deals` table. Everything about a deal (creation date,
owner, pipeline stage, lost reason) is an event row in `deal_changes` (`deal_id`,
`change_time`, `changed_field_key`, `new_value`). It is an EAV-style change log covering
**1,995 distinct deals** (`analyses/exploration_deal_changes_field_breakdown.sql`).

Findings that shaped the model, each backed by a runnable query in `analyses/`:

1. **`stage_id` history is not monotonic, and deals skip stages.** Deals can jump forward
   (2 to 5) or revisit earlier stages (8 to 1). 2,510 of 8,906 `stage_id` changes are
   such "non-step" transitions, and **84% of deals reach a stage without recording every
   prior stage** (`analyses/exploration_stage_id_non_monotonic.sql`). This drives the
   central modeling decision in Section 5a: how to count a funnel step when stages are
   skipped.
2. **`lost_reason` is populated for ~100% of deals** (5 reasons, ~380 to 425 each, evenly
   distributed). That looks like synthetic fill rather than a genuine "deal lost" signal,
   so it is treated as metadata only and does **not** filter deals out of the funnel. The
   same query shows 5 deals with a duplicate `add_time`/`lost_reason` entry, unused by the
   funnel model so harmless (`analyses/exploration_lost_reason_distribution.sql`).
3. **`activity.done` is roughly 50/50 per activity type.** About half of `meeting`/`sc_2`
   activities are scheduled but not completed
   (`analyses/exploration_activity_done_split.sql`).
4. **`activity_id` is not unique:** 11 duplicate ids across 4,579 rows
   (`analyses/exploration_activity_id_duplicates.sql`), so it is not used as a primary key
   anywhere downstream (see Section 7).

## 4. Architecture

```
sources (raw Postgres tables)
   |
   v
staging/pipedrive/            1:1 cleaned, renamed, typed views
   stg_pipedrive__activity
   stg_pipedrive__activity_types
   stg_pipedrive__deal_changes
   stg_pipedrive__stages
   |
   v
intermediate/                 business logic, still grain-preserving
   int_deal_stage_history      one row per deal per stage entered (back-filled)
   int_deal_sales_call         completed Sales Call 1/2 activities
   |
   v
marts/reporting/
   rep_sales_funnel_monthly    final aggregated report
```

Each `int_` model exposes a surrogate key (`deal_stage_sk`, `deal_sales_call_sk`, built
with `dbt_utils.generate_surrogate_key`) with `unique` and `not_null` tests, giving every
intermediate model a tested primary key independent of the source `activity_id`
(see Section 7).

`users` and `fields` are documented in the sources YAML for full schema understanding but
have no staging models. They are not needed for this report, so no models were built "just
in case."

## 5. Key Design Decisions

### a) Cumulative "entered stage" logic for Steps 1 to 9 (Pipedrive convention)

This is the most important modeling decision. Because 84% of deals skip at least one
stage, the count at each step depends entirely on how skipped stages are treated. Two
defensible options:

- **Explicit milestone:** count a deal at a stage only if it explicitly logged a change to
  that stage. Faithful to the raw events, but it understates the funnel: a deal that jumps
  2 to 5 is never counted at stages 3 and 4.
- **Cumulative / back-filled (chosen):** a deal that reached stage N counts as having
  entered every stage 1 to N. This matches **Pipedrive's own Insights deal progress
  report**, which states: "The entered stage deal count also includes deals that have
  skipped that stage while moving on to a future stage. For example, if a deal has moved
  from stage two directly to stage five in the time frame selected, it will show as
  having entered stages three, four and five"
  ([Pipedrive: Insights reports - deal progress](https://support.pipedrive.com/en/article/insights-reports-deal-progress)).

I chose cumulative back-fill so the report means the same thing Enpal's sales team sees
natively in Pipedrive. The difference is large: Stage 5 is 894 deals under explicit
counting versus **1,693** back-filled. A deal "enters" stage k at the moment it first
reached stage k or later (`MIN(changed_at)` over events with `stage_id >= k`), so skipped
stages are attributed to the month of the jump that carried the deal past them. The result
is a properly monotonic funnel.

**Why we have to back-fill (the data does not already contain it).** Pipedrive's
back-fill is a rule its *reporting engine* applies at query time; it is never written
back into the raw event log we were given. When a rep moves a deal forward, Pipedrive
records a single "now at stage N" event, not one event per intermediate stage.
Concrete example, deal `680288`: the raw `deal_changes` export holds exactly two stage
events (stage 1, then stage 9), yet Pipedrive's report counts it in all nine stages.
Our model reproduces those nine rows from the two raw events. Reconstructing that
reporting logic from the source event stream is the actual task; if the export already
contained the back-filled rows there would be nothing to model.

### b) Steps 2.1 / 3.1 use `done = true` activities only

About 50% of `meeting`/`sc_2` activities are `done = false` (scheduled but not completed).
Rather than guess, I checked Pipedrive's own product conventions: their "marked as done"
logic and Insights activity reports both filter on `done = true` for completed activity
counts ([source](https://support.pipedrive.com/en/article/activity-marked-as-done-logic),
[source](https://support.pipedrive.com/en/article/insights-reports-activities-performance)).
This keeps the semantics consistent with (a): both represent the deal actually reaching a
milestone, not something merely scheduled.

### c) `funnel_step` as `numeric(3,1)`

Stores `1, 2, 2.1, 3, 3.1, 4 ... 9`, which sorts naturally in any BI tool without extra
logic and directly encodes the brief's "Step 2.1 / 3.1" sub-step notation.

### d) `kpi_name` uses source `stage_name` verbatim

For example "Qualified lead" (lowercase from the source `stages` table) rather than
re-casing to "Qualified Lead". This preserves traceability back to the CRM's own labels.
It is worth flagging as a quick discussion point: trivial to normalize if the BI team
prefers consistent casing.

## 6. Result and Initial Insights

`dbt build` produces 1 table, 6 views, and **42 passing tests**. Aggregated across all
months (2024-01 to 2025-02), using the cumulative "entered stage" logic from Section 5a:

| Step | KPI | Deals entered | Conversion from prior step |
|---|---|---:|---:|
| 1 | Lead Generation | 1,995 | 100% of all deals |
| 2 | Qualified lead | 1,990 | 99.7% |
| 2.1 | Sales Call 1 | 568 | 28.5% of Qualified leads |
| 3 | Needs Assessment | 1,951 | 98.0% |
| 3.1 | Sales Call 2 | 560 | 28.7% of Needs Assessment |
| 4 | Proposal/Quote Preparation | 1,862 | 95.4% |
| 5 | Negotiation | 1,693 | 90.9% |
| 6 | Closing | 1,424 | 84.1% |
| 7 | Implementation/Onboarding | 1,081 | 75.9% |
| 8 | Follow-up/Customer Success | 723 | 66.9% |
| 9 | Renewal/Expansion | 324 | 44.8% |

**Observations:**

- Step 1 total (1,995) exactly matches the total distinct deal count, and the funnel is
  properly monotonic. This confirms no deals are dropped and the back-fill is consistent.
- The top of the funnel is very healthy (~95 to 99% progression through Proposal). The real
  attrition is late-funnel: Closing to Onboarding (76%), Onboarding to Follow-up (67%), and
  the steepest, Follow-up to Renewal/Expansion (45%). Retention and expansion, not
  qualification, is where deals are lost.
- Sales-call logging is strikingly low: only ~28% of deals at the relevant stage have a
  completed Sales Call 1/2 logged, despite ~99% reaching Qualified/Needs Assessment. This
  is a strong signal to take to the business: are calls under-logged in the CRM, or are
  deals genuinely advancing without a recorded call?

## 7. Data Quality and Testing

42 tests across all layers:

- `not_null` and `unique` on natural keys (`stage_id`, `activity_type_code`, and others)
  and on the surrogate keys (`deal_stage_sk`, `deal_sales_call_sk`) on the intermediate
  models.
- `accepted_values` on enums (`changed_field_key`, `activity_type_code`, `kpi_name`,
  `funnel_step`). These double as living documentation of the domain.
- `dbt_utils.unique_combination_of_columns` on the report grain `(month, funnel_step)`,
  which guarantees exactly one row per funnel step per month.

Surrogate keys use `dbt_utils.generate_surrogate_key` (cross-database, null-safe) rather
than hand-rolled hashing.

**Known source data quality issue:** raw `activity.activity_id` has 11 duplicate ids across
4,579 rows, so it is deliberately not given a `unique` test in `stg_pipedrive__activity`,
just `not_null`, with the caveat documented in the column description.
`int_deal_sales_call` instead derives its primary key from `(deal_id, activity_type_code)`,
which is unique for completed Sales Call 1/2 activities.

## 8. SQL Efficiency Notes

- Staging and intermediate layers are views: no storage cost, always reflect the latest
  source data, and the Postgres planner can collapse them into the final query.
- Only the final mart is materialized as a table, since it is the one model downstream BI
  tools query repeatedly.
- `rep_sales_funnel_monthly` does a single `union all` of two pre-aggregated-grain CTEs
  followed by one `group by`, which avoids repeated scans of `deal_changes` / `activity`
  for each funnel step.
- `int_deal_stage_history` aggregates `deal_changes` down to one row per `(deal, stage)`
  before the join to `stages`, which keeps the join cheap (9-row dimension).
- The models are warehouse-portable: `ref`, `source`, and `dbt_utils` keep them free of
  Postgres-specific syntax beyond the `date_trunc`/cast idioms, so they would move to a
  cloud warehouse such as Snowflake with minimal change.

## 9. Possible Future Enhancements

- Build a `dim_deal` (one row per deal) as a reusable backbone, collapsing `deal_changes`
  into current stage, owner, `add_time`/created date, and lost reason per deal. This funnel
  report is deliberately scoped to the brief, but a `dim_deal` is the natural next model: it
  would let `int_deal_stage_history` and `int_deal_sales_call` join to deal attributes and
  power owner, cohort, and reason-level analysis beyond this report.
- Zero-fill the month by funnel_step grid (date spine) so BI tools do not need to handle
  sparse months.
- Bring in `users` for rep and owner-level funnel breakdowns.
- Add conversion-rate columns directly in the mart (or a downstream model) rather than
  computing them ad hoc.
- If `deal_changes` grows large, switch `int_deal_stage_history` to an incremental model
  keyed on `change_time`.
