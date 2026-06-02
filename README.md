# dbt Enpal Assessment — Pipedrive Sales Pipeline Analytics

## Overview

This project builds a modular dbt analytics layer on top of raw Pipedrive CRM data loaded into a local Postgres instance. The goal was to deliver the required `rep_sales_funnel_monthly` reporting model while building a full, production-grade pipeline that answers the deeper questions the funnel table alone would raise.

---

## Setup

1. Install and launch Docker Desktop.
2. Fork and clone this repo, then run `docker compose up` from the project root.
3. Connect to the local Postgres database:
   ```
   Host: localhost  |  User: admin  |  Password: admin  |  Port: 5432
   ```
4. Install dependencies:
   ```bash
   pip install dbt-core dbt-postgres
   # or, if using uv:
   uv run dbt debug --profiles-dir .
   ```
5. Run the full pipeline:
   ```bash
   uv run dbt build --profiles-dir .
   ```

All models are built into the `public_pipedrive_analytics` schema.

---

## Architecture

The project follows a standard three-layer dbt structure:

```
sources (raw Postgres tables)
    ↓
staging/   — views: rename columns, cast types, document sources
    ↓
intermediate/  — tables: complex transformations, reusable grain models
    ↓
reporting/     — tables: final consumer-facing models
```

**Why three layers?**
Each layer has a single responsibility. Staging creates a stable contract with the source — if a raw column is renamed, only the staging model needs to change. Intermediate isolates complex logic (event log pivot, deal lifecycle summary) so it can be reused and tested independently. Reporting models are intentionally thin, reading like "select these columns from this clean table."

**Materialization decisions:**
Staging models are `views` (no storage cost, always fresh). Intermediate models are `tables` because `int_deal_monthly_snapshot` is referenced by four downstream models — as a view it would re-execute the expensive cross-join four times per `dbt run`. Reporting models are `tables` for query performance.

---

## Source Data

Six raw tables from a Pipedrive CRM export:

| Table | Description |
|---|---|
| `deal_changes` | Event log — one row per field change on a deal. Core source. |
| `stages` | Lookup: 9 funnel stages from Lead Generation to Renewal/Expansion. |
| `users` | Salespeople. Used for ownership attribution. |
| `fields` | Field metadata including JSONB enum options for stage_id and lost_reason. |
| `activity` | Activities (calls, emails) logged against deals. |
| `activity_types` | Reference for activity type names. |

---

## Models

### Staging (`models/staging/`)

| Model | Description |
|---|---|
| `stg_deal_changes` | Typed, renamed event log. Renames `change_time → changed_at`, `changed_field_key → field_key`. |
| `stg_stages` | Stage lookup. Used for joins throughout the pipeline. Note: stage label consistency against `stg_fields` is enforced by the `assert_stages_match_field_options` test rather than by unpacking here — this keeps the two sources intentionally separate so divergence is caught explicitly. |
| `stg_users` | User/salesperson reference. |
| `stg_fields` | Unpacks `field_value_options` JSONB into one row per `(field_key, option_id, label)`. Prevents hardcoded CASE statements across the project — label changes in Pipedrive propagate automatically on the next `dbt run`. |
| `stg_activity` | Activities, deduplicated on `activity_id` (source data quality issue found during exploration). |
| `stg_activity_types` | Activity type reference. |

### Intermediate (`models/intermediate/`)

**`int_deal_monthly_snapshot`**
Transforms the event log into a point-in-time snapshot with deal × calendar month granularity. The monthly interval follows the assessment's own framing — performance is measured monthly — and is an intentional pre-aggregation choice. Worth noting: pre-aggregating to monthly means intra-month movements are not visible; if daily granularity were needed, the date spine and grain would need to change, though the logic would remain the same.

To build the snapshot, we generate a date spine (one row per calendar month across the full data window) and cross-join it with each deal from its creation month onward. For each deal × month pair, we resolve the most recent stage and owner as of the last second of that month using `DISTINCT ON` — which Postgres documentation identifies as more efficient than a `ROW_NUMBER()` window function for this pattern. Both `is_churned` (carries forward from the month of loss) and `is_lost_this_month` (fires once) are exposed because they answer different questions and collapsing them would break one of the two use cases.

If migrating to a different warehouse, `DISTINCT ON` is replaced by `ROW_NUMBER()` via the `last_record_per_group` macro.

**`int_deal_summary`**
Deal-level granularity. Captures the full lifecycle: creation date, final stage (last stage before loss), `max_stage_reached_id` (highest stage ever visited — useful for conversion rate approximations when deals skip stages), lost reason, owner, days in pipeline, stages touched, and `all_lost_reasons_history` (chronological string of all lost reasons for deals re-opened and re-closed multiple times).

### Reporting (`models/reporting/`)

**`rep_sales_funnel_monthly`** *(required by assessment)*
Monthly funnel counts per stage. `deals_count` = active non-churned deals at each stage at month-end. Steps 2.1 (Sales Call 1) and 3.1 (Sales Call 2) are derived from the activity table by matching completed activities to the deal's stage at the time. In practice, both steps return zero counts — after investigation, only 8 deal IDs overlap between the activity and deal_changes tables, and the timing of those activities does not align with the deals being in stages 2 or 3. See data findings for the full investigation.


I included the following tables in addition to the required assessment in order to preemptively answer follow up questions. 

**`rep_deal_status_monthly`**
Dashboard-ready pivot of deal lifecycle at deal × month granularity. Null owner → `'Unassigned'`, null stage → `'Registered – Awaiting Stage Assignment'`. Lost reason is carried forward across all churned months so dashboard filters work correctly.

In a tool like Tableau, this table works well as the base of a **deal timeline view**: deals as rows, months as columns, stage as colour — similar to a Gantt chart. This gives analysts the ability to trace any individual deal's journey and filter cohorts by lost reason, owner, or stage. For a higher-level view of how deals are flowing between stages month over month, `rep_stage_movement_monthly` is the right table to use alongside or as a drill-through.

**`rep_stage_movement_monthly`**
The "double click" on `rep_deal_status_monthly` — same monthly grain but aggregated to stage level. Shows how many deals are new to the funnel, stayed in the same stage, or moved in from another stage each month, plus how many were lost from each stage. High "stayed" counts at early stages signal stalling; "moved_in" shows progression velocity.

Because both this model and `rep_deal_status_monthly` share the same monthly granularity, they could be merged into a single wider table depending on the BI tool and use case. In Tableau, for example, linking them as a detail/summary pair gives natural drill-through behaviour without needing to merge.

**`rep_stage_funnel_analysis`**
Drop-off analysis at lost month × final stage × lost reason granularity. `is_duplicate_entry` flags "Duplicate Entry" losses separately, with `deals_lost_excl_duplicates` and `pct_of_monthly_losses_excl_duplicates` for cleaner signals. See data findings for the caveat on duplicate verification.

**`rep_salesperson_performance`**
Monthly scorecard per rep: pipeline size, deals lost, deals reaching Closing (stage 6), deals won (stage 9), `total_deals_worked`, `conversion_rate_pct`, `avg_days_to_loss`, `avg_days_to_win`, and all-time coaching signals (`most_common_lost_stage`, `most_common_lost_reason`).

Sales managers typically need cross-rep visibility that is hard to get from a CRM's native views. Pipedrive does provide individual rep dashboards natively, but they are scoped to that rep's own pipeline and do not support comparative analysis or custom metric definitions. If this model gets traction, a natural next step would be a deal-level version (essentially `int_deal_summary` filtered and enriched per owner) so individual reps can use it as a personal tracker — useful if they lack CRM access or if the team works across multiple tools.
---

## Data Findings

### 1. Low overlap between activity and deal_changes

After investigation, only **8 deal IDs** exist in both the `activity` and `deal_changes` tables. The `activity` table contains ~1,000 rows across four activity types (`after_close_call`, `follow_up`, `meeting`, `sc_2`), but the vast majority of deals in `deal_changes` have no corresponding activity records.

For the 8 overlapping deals, the timing of their activities does not align with those deals being in stage 2 or 3 in the monthly snapshot, so steps 2.1 and 3.1 return zero counts in `rep_sales_funnel_monthly`. The modelling logic is correct — the limitation is in the source data.

**Hypothesis:** Activity logging was not consistently maintained in Pipedrive, or the activity export covers a different time window than deal_changes.

**Recommended action:** Raise with source engineering and audit the Pipedrive API connection. 

### 2. Deals skip funnel stages routinely

Many deals jump from stage 2 directly to stage 5, or stage 1 to stage 4, without passing through intermediate stages. This is expected in solar energy sales, but means true conversion rates between adjacent stages cannot be calculated directly.

**An approximation is possible** using `max_stage_reached_id` in `int_deal_summary`, which records the highest stage a deal ever visited regardless of the path taken. A "funnel reach rate" for stage X can then be defined as: deals where `max_stage_reached_id >= X` divided by total deals that entered the funnel. This is not a true conversion rate (it doesn't account for time or sequence) but is a defensible upper-bound estimate given the data.

### 3. Some deals have multiple lost_reason events

The data contains deals with more than one `lost_reason` event — indicating they were re-opened and re-closed, or the API wrote the event twice. Both intermediate models deduplicate to the most recent event. The `all_lost_reasons_history` column in `int_deal_summary` preserves the full sequence.

### 4. Duplicate Entry as a lost reason cannot be verified

Deals marked as lost with reason "Duplicate Entry" are flagged in `rep_stage_funnel_analysis` via `is_duplicate_entry`. Without a customer identifier in the dataset it is not possible to confirm whether these are genuine duplicates or mislabelled. These losses should be excluded from performance metrics until cross-referenced against a customer ID reference table.

### 5. No explicit "won" event

There is no `status = won` event in `deal_changes`. Stage 9 (Renewal/Expansion) is used as the "won" proxy throughout. This is documented as an assumption across all models.

### Why these findings led to additional models

The required `rep_sales_funnel_monthly` delivers monthly deal counts per stage. But working through the data raised immediate follow-up questions that a single table cannot answer:

- The activity overlap finding raises the question of *where* deals are actually dropping off, and *why* — leading to `rep_stage_funnel_analysis`.
- The stage-skipping finding raises the question of *how fast* deals are actually moving and *who* is driving progression — leading to `rep_salesperson_performance`.
- Wanting to see whether deals are stalling or moving, and from where, led to `rep_stage_movement_monthly`.
- Having per-deal, per-month status available as a base for any of the above analyses led to `rep_deal_status_monthly`.

Rather than deliver a single metric and wait for the questions, these models provide the foundation to act on the data immediately.

---

## Tests

Six singular tests in `tests/`, each targeting a specific type of silent failure — data issues that produce wrong numbers without throwing an error.

`assert_rep_deal_status_monthly_unique_grain` enforces that the main dashboard table has exactly one row per deal per month. This is the most important test in the project: if a duplicate row exists, every KPI a stakeholder reads from this table would be inflated without any visible error. Grain integrity is the foundation everything else rests on.

`assert_lost_deals_have_final_stage` checks that every deal marked as lost has a recorded stage. A lost deal with no stage is invisible in drop-off analysis — it churned but doesn't appear in any stage's loss count.

`assert_stage_ids_within_range` checks that all stage values in the event log fall between 1 and 9. A stage outside this range would produce a null stage name across every model that joins to the stages table, silently creating unmapped rows.

`assert_lost_reason_values_known` checks that all lost reason codes match the five known values from the fields table. If Pipedrive adds a new reason code, this test surfaces it immediately before it propagates as null labels into reporting.

`assert_no_stage_change_before_deal_created` checks that no stage or user event is recorded before the deal's `add_time` event. If a stage change predates the deal's creation (due to clock skew, timezone issues, or a bad import), that deal would appear in the monthly snapshot for months before it existed — inflating early pipeline counts and understating later ones.

`assert_stages_match_field_options` checks for divergence between the `stages` lookup table and the stage IDs defined in `fields.field_value_options`. Both are maintained independently in Pipedrive — if a new stage is added to one but not the other, it creates silent null labels in reporting. If divergence were detected, a natural next step would be a `generate_missing_stages` macro that reads `fields.field_value_options` and auto-populates any missing rows into the stages table, making the resolution self-service rather than manual.

Schema tests (`not_null`, `unique`, `accepted_values`) are also defined for every model column in the `_staging.yml`, `_intermediate.yml`, and `_reporting.yml` files.

---

## Macros

Three macros in `macros/` abstract Postgres-specific SQL patterns for cross-warehouse compatibility. This project was developed locally on Postgres; the macros are a forward-looking addition given the assumption that Enpal's production environment runs on Snowflake — removing the need for script-level changes at migration time.

| Macro | Postgres pattern | Snowflake / BigQuery equivalent |
|---|---|---|
| `last_record_per_group` | `DISTINCT ON (...)` | `ROW_NUMBER()` window function |
| `generate_monthly_spine` | `generate_series(...)` | `GENERATOR` / `GENERATE_DATE_ARRAY` |
| `end_of_month_ts` | `interval '1 month - 1 second'` | `DATEADD` equivalents |

Each macro uses `target.type` to emit the correct dialect at compile time.
