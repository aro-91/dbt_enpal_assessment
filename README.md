# Enpal Analytics Engineer Take-Home: Sales Funnel

## Solution

This repo builds `rep_sales_funnel_monthly`, a monthly Pipedrive sales-funnel report
(`month`, `kpi_name`, `funnel_step`, `deals_count`) covering funnel steps 1-9 plus
sub-steps 2.1 (Sales Call 1) and 3.1 (Sales Call 2).

**Run it:**
```bash
docker compose up -d                              # start Postgres + load raw CSVs
source ~/.virtualenvs/dbt_env/bin/activate        # activate the dbt virtualenv
DBT_PROFILES_DIR=. dbt deps                         # install dbt_utils
DBT_PROFILES_DIR=. dbt build                       # build all models + run tests
```
Results land in the `public_pipedrive_analytics` schema (final model:
`rep_sales_funnel_monthly`). Browse the model docs/lineage with
`DBT_PROFILES_DIR=. dbt docs generate && DBT_PROFILES_DIR=. dbt docs serve`.

**Model layout** (`sources → staging → intermediate → marts`):
```
models/staging/pipedrive/     stg_pipedrive__{activity, activity_types, deal_changes, stages}
models/intermediate/          int_deal_stage_history, int_deal_sales_call
models/marts/reporting/       rep_sales_funnel_monthly   ← deliverable
analyses/                     exploration queries backing each data-quality finding
```
Uses `dbt_utils` (`generate_surrogate_key`, `unique_combination_of_columns`); run
`DBT_PROFILES_DIR=. dbt deps` before the first build.

**Key modeling decision:** stage steps use Pipedrive's own funnel convention, a deal
that reaches a stage counts as having entered every earlier stage (skipped stages
back-filled), since 84% of deals skip a stage. Sales Call steps count completed
(`done = true`) activities only.

**Docs:** [`NOTES.md`](NOTES.md) is the written walkthrough (approach, source-data
exploration, design decisions, results, and insights).

---

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
