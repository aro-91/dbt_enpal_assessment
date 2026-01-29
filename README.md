## Enpal Senior Analytics Engineer Take-Home (dbt + Pipedrive CRM)

This project models a subset of Pipedrive CRM data into a monthly sales funnel reporting table:
`rep_sales_funnel_monthly` with columns `month`, `kpi_name`, `funnel_step`, `deals_count`.

## Setup

1. Download Docker Desktop (if you don’t have installed) using the official website, install and launch.
2. Fork this Github project to you Github account. Clone the forked repo to your device.
3. Open your Command Prompt or Terminal, navigate to that folder, and run the command `docker compose up`.
4. Now you have launched a local Postgres database with the following credentials:
 ```
    Host: localhost
    User: admin
    Password: admin
    Port: 5432
```
5. Connect to the db via a preferred tool (e.g. DataGrip, Dbeaver etc)
6. Install dbt-core and dbt-postgres using pip (if you don’t have) on your preferred environment.
7. Now you can run `dbt run` with the test model and check public_pipedrive_analytics schema to see the dbt result (with one test model)

## Project
1. Remove the test model once you make sure it works
2. Dive deep into the Pipedrive CRM source data to gain a thorough understanding of all its details. (You may also research the Pipedrive CRM tool terms).
3. Define DBT sources and build the necessary layers organizing the data flow for optimal relevance and maintainability.
4. Build a reporting model (rep_sales_funnel_monthly) with monthly intervals, incorporating the following funnel steps (KPIs):
  &nbsp;&nbsp;&nbsp;Step 1: Lead Generation
  &nbsp;&nbsp;&nbsp;Step 2: Qualified Lead
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Step 2.1: Sales Call 1
  &nbsp;&nbsp;&nbsp;Step 3: Needs Assessment
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Step 3.1: Sales Call 2
  &nbsp;&nbsp;&nbsp;Step 4: Proposal/Quote Preparation
  &nbsp;&nbsp;&nbsp;Step 5: Negotiation
  &nbsp;&nbsp;&nbsp;Step 6: Closing
  &nbsp;&nbsp;&nbsp;Step 7: Implementation/Onboarding
  &nbsp;&nbsp;&nbsp;Step 8: Follow-up/Customer Success
  &nbsp;&nbsp;&nbsp;Step 9: Renewal/Expansion
5. Column names of the reporting model: `month`, `kpi_name`, `funnel_step`, `deals_count`
6. “Git commit” all the changes and create a PR to your forked repo (not the original one). Send your repo link to us.

## Data overview (source tables)

The raw Pipedrive tables used in this assessment:
- `activity`: sales activities linked to deals (includes type, assignee, completion flag, due timestamp)
- `activity_types`: dictionary of activity types (includes Yes/No active flag)
- `deal_changes`: event log capturing changes on deals (e.g. stage_id, user_id, add_time, lost_reason)
- `stages`: stage dictionary (in this dataset, stages map to funnel steps 1–9)
- `users`: users dimension
- `fields`: metadata / enumerated value mappings (jsonb options)

## Modeling approach

### Layering
The project follows a standard dbt layering approach:

- **Sources** (`models/sources.yml`)
- documents raw tables and basic column tests
- **Staging** (`models/staging/`)
- typecasting, naming standardization, and deduplication of exact duplicates
- adds surrogate keys where source identifiers are not unique (e.g. `activity_sk`)
- **Intermediate** (`models/intermediate/`)
- transforms staged data into business events used by reporting
- **Marts** (`models/marts/`)
- final reporting model: `rep_sales_funnel_monthly`

### Key models
**Staging**
- `stg_activity` – cleaned activities, deduped, with `activity_sk`
- `stg_deal_changes` – cleaned deal change events
- `stg_stages`, `stg_users`, `stg_activity_types`, `stg_fields` – – reference dimensions / dictionaries kept as reusable building blocks for future reporting and joins, even if not all are consumed directly by the final mart

**Intermediate**
- `int_deal_stage_events` – stage entry events derived from `deal_changes` where `changed_field_key = 'stage_id'`
- `int_sales_call_events` – completed sales call events derived from `activity`:
- `meeting` → Sales Call 1 (step 2.1)
- `sc_2` → Sales Call 2 (step 3.1)
- `int_deal_created` – deal creation timestamp derived from `deal_changes` where `changed_field_key = 'add_time'`
(kept as a reusable building block for lifecycle analyses; not required for the funnel output)

### Funnel definition
`rep_sales_funnel_monthly` counts distinct deals that entered a funnel step during each calendar month:
- Steps **1–9** come from **stage entry** events (stage_id 1..9)
- Steps **2.1** and **3.1** come from **completed sales call activities** linked to deals

A deal may appear in multiple steps and multiple months as it progresses through the funnel.

### Model materialization strategy

Materializations are defined centrally in `dbt_project.yml`:

- staging → views
- intermediate → views
- marts → tables

**Why staging is materialized as views**
Staging models are the “entry point” for each source table and are lightweight: renaming, typecasting, and basic standardization. Keeping them as views avoids persisting redundant copies of raw data while providing consistent cleaned building blocks downstream.

**Why intermediate is materialized as views**
Intermediate models capture business events (stage entry events, sales call events, deal creation timestamps). In production, intermediate models may be materialized as tables if they are expensive to compute or heavily reused. In this assessment, the dataset is small and the intermediate models are used primarily to build the final mart, so materializing them as views keeps the project simple and easy to reason about. If query performance became a concern, the intermediate layer would be the first place investigate materialization.

**Why marts are materialized as tables**
The mart (`rep_sales_funnel_monthly`) is the analytics-facing reporting artifact. Persisting it as a table improves query performance for BI and avoids recomputing upstream joins/logic at query time.

**Why not incremental here**
Incremental models are most beneficial when data is large and regularly updated, so dbt can process only new/changed rows and reduce runtime. This assessment dataset is static and small enough to rebuild fully, so incremental adds unnecessary complexity without practical benefit.

## Testing

### Built-in dbt tests (YAML)
- schema tests for not_null / unique / accepted_values / relationships in staging + intermediate + mart models

### Dynamic threshold test (example guardrail)
A custom generic test `dynamic_threshold` is applied to `rep_sales_funnel_monthly.deals_count` grouped by `funnel_step`.
This is intended as an example of an anomaly-detection guardrail (spike detection) that can be useful in production.

Note: this assessment dataset is static; because the test uses `current_date` to define “recent” windows,
it may behave as a no-op if the dataset does not contain rows in the configured recent period. In a
scheduled pipeline with fresh monthly loads, it would help detect unexpected volume shifts per funnel step.
