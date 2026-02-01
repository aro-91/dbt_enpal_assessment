# dbt Enpal Assessment – Sales Funnel Modeling

## Overview
This project models a **monthly sales funnel** based on Pipedrive data.  
The objective is to deliver a reliable reporting table that shows how deals progress
through funnel stages and key activities over time.

The solution emphasizes:
- Clear data contracts
- Explicit grain definitions
- Separation between raw data, business logic, and reporting logic
- Robustness against upstream configuration changes

## Data Sources

The following Pipedrive tables are used (via Postgres):

- deal_changes – Historical changes to deal fields
- stages – Deal stage metadata
- activity – Sales activities linked to deals
- activity_types – Metadata for activity classification
- fields – Field metadata and allowed option values

## Modeling Approach
### Layered dbt Structure

The project follows a standard dbt layering pattern:
staging → intermediate → marts

#### Staging (stg_*)

- Minimal transformations
- Column renaming and light type cleanup
- No business logic
- Models closely mirror the source system

#### Intermediate (int_*)

- Business logic and event modeling
- Explicit grain defined per model
- Designed to be reusable and stable

##### Key intermediate models:

- **int_pipedrive_deal_stage_changes**
Models deal stage transitions as events with stage entry and exit timestamps (one row per deal per stage entry).

- **int_pipedrive_deal_activity_changes**
Derives activity-based activity events (first completed qualifying activity per deal and stage).

#### Reporting / Marts (rep_*)

- Business-facing reporting models
- Funnel step naming and ordering applied here
- Aggregated outputs optimized for BI consumption

##### Final output:

- rep_sales_funnel_monthly

### Funnel Definition

The funnel is modeled as event-based, not snapshot-based.

#### Stage-based Steps

Derived from deal stage transitions:

- Step 1: Lead Generation
- Step 2: Qualified Lead
- Step 3: Needs Assessment
- Step 4: Proposal / Quote Preparation
- Step 5: Negotiation
- Step 6: Closing
- Step 7: Implementation / Onboarding
- Step 8: Follow-up / Customer Success
- Step 9: Renewal / Expansion

#### Activity-based Steps

Some funnel steps represent sales actions, not stages:

- Step 2.1: Sales Call 1
- Step 3.1: Sales Call 2

### Data Quality & Contracts

- not_null and unique tests applied where applicable
- Surrogate keys used for event models when the source does not provide stable identifiers
- Final reporting mart enforces a dbt contract to guarantee schema stability

### Metadata-driven Validation

Instead of hard-coding allowed values:
- Pipedrive field metadata (fields) is used to validate stage change events
- This detects upstream configuration changes early and avoids brittle assumptions

### Design Decisions & Trade-offs

- Event-based modeling preserves full historical context
- Stage transitions and activities are modeled separately because they represent different grains and business concepts. This keeps each model’s grain explicit, and simplifies validation.
- Funnel step naming is applied only in the reporting layer
- Kimball principles are applied conceptually without enforcing rigid naming conventions

## Observations & Insights

- No deals reached Step 2.1 (Sales Call 1) or Step 3.1 (Sales Call 2) during the observed period.
- The `activity_id` appears to be reliably unique only for completed activities (`is_done = true`).

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
7. Now you can run `dbt deps` then `dbt run` 