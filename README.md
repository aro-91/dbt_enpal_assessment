# Sales Funnel Analytics - Assessment Submission
**Author:** Sakura Hayashi  
**Date:** 31 October 2025

### Overview
Built a monthly sales funnel report for the Analytics Engineer assessment to analyse deal progression across nine pipeline stages, supplemented with sales call activity metrics for deeper performance insights.

### Implementation Approach

**Data Sources:**
- `deal_changes` - Stage progression tracking
- `stages` - Funnel stage definitions  
- `activity` - Sales call activities

**Model:** `rep_sales_funnel_monthly`

**SQL Strategy:**
1. Extracted stage changes (`field_key = 'stage_id'`)
2. Aggregated by month using `DATE_TRUNC`
3. Joined with stages table for stage names
4. Added Sales Call 1 and 2 from activity table
5. Combined metrics using `UNION ALL`

### SQL Optimisations & Best Practices:

**Early Filtering in CTEs**
- Applied `WHERE` clauses at CTE level to reduce data volume before joins
  - `WHERE changed_field_key = 'stage_id'` filters majority of rows immediately
- Minimises processing time and memory usage

**Distinct Counting**
- `COUNT(DISTINCT deal_id)` prevents double-counting when deals move through multiple stages in the same month
- Ensures accurate deal counts per funnel step

**Explicit Type Casting**
- Cast `funnel_step` to `NUMERIC` for type consistency across  `UNION`
- Main stages return `INTEGER` (1-9), sub-steps return `NUMERIC` (2.1, 3.1)
- Prevents type mismatch errors and makes intent explicit

**UNION ALL Over UNION**
- `UNION ALL` avoids expensive duplicate-checking operation
- Stage changes and activity metrics are mutually exclusive (no duplicates possible)
- Provides performance improvement over `UNION`

**Modular CTEs**
- Organised query into logical components for readability and maintainability
- Each CTE handles one transformation step
- Easier to debug and modify individual sections

### Key Findings

### Data Quality & Key Observations

**Data Coverage & Timeline**
- Dataset spans 14 months (January 2024 - February 2025)
- Peak activity in mid-2024 (May-August) with 240+ deals entering Lead Generation monthly
- Declining trend in late 2024, suggesting seasonal patterns or data cutoff

**Critical Finding: 100% Deal Loss Rate**
- All deals in the dataset ultimately have a `lost_reason` entry
  - No successfully closed deals remain active without a loss reason
- This suggests either:
  - Test/demo data created for assessment purposes?
  - Historical snapshot of only unsuccessful deals?
  - Real data from a struggling sales period?
- Verified by querying: 
  - `deal_changes` contains stage progressions but no "won" status field
  - `lost_reason` appears for every unique `deal_id`
  - Even deals reaching stage 9 (Renewal/Expansion) eventually marked as lost

**Hypotheses:**
1. **Test/Demo Data (Most Likely)**
   - Identical timestamps for multiple stage changes suggest synthetic data
      - E.g., deal 166143 has all changes at 09:44:32, indicating bulk data import or system-generated test data rather than organic CRM activity
   - Deals progress unrealistically fast
      - E.g., deal 102496 went from Renewal/Expansion to Lost due to product mismatch in 9 days
      - Real-world deals typically spend weeks/months in each stage

2. **Filtered Historical Dataset**
   - Dataset may contain only lost deals for analysis of failure patterns
   - Won deals might be in a separate table or excluded intentionally
   - Common in churn analysis or loss-reason reporting

3. **Missing "Won" Status Field**
   - CRM may track "closed-won" differently than stages
   - Pipedrive might use another status field separate from `stage_id` (e.g., won/lost/open)
   - Data export may not include the status field, only stage progression

4. **Business Reality (Unlikely)**
   - If real data: 0% win rate indicates severe sales problems
   - Would require immediate executive attention

In production:
- Would investigate why win rate is 0% and look into other filtering options or additional data sources
- Investigate schema design: Does Pipedrive track won/lost status separately from stages?
- Query for a status field in source system
- Verify data export parameters with data engineering team
- If real 0% win rate: escalate to sales leadership immediately

**Pipeline Funnel Behavior**
- Despite 100% loss rate, funnel shows expected narrowing pattern
- Total deal progression across all months (January 2024 - February 2025):

| Funnel Step | Stage Name | Total Deals | Conversion from Previous |
|-------------|------------|-------------|--------------------------|
| 1 | Lead Generation | 2,000 | - |
| 2 | Qualified Lead | 1,305 | 65.3% |
| 2.1 | Sales Call 1 | 1,145 | 87.7% of Qualified |
| 3 | Needs Assessment | 1,140 | 87.4% |
| 3.1 | Sales Call 2 | 1,124 | 98.6% of Assessment |
| 4 | Proposal/Quote Preparation | 1,087 | 95.4% |
| 5 | Negotiation | 895 | 82.3% |
| 6 | Closing | 657 | 73.4% |
| 7 | Implementation/Onboarding | 518 | 78.8% |
| 8 | Follow-up/Customer Success | 479 | 92.5% |
| 9 | Renewal/Expansion | 324 | 67.6% |

- Overall conversion rate: 16.2% of leads reach Renewal/Expansion (324/2,000)
- Largest drop-off: Negotiation -> Closing (26.6% drop)
- Strong retention: Closing -> Implementation (78.8% continue)

**Sales Activity Tracking**
- Sales Call 1 and Sales Call 2 tracked independently from stage progression
- Call volumes sometimes exceed deal counts at corresponding stages (e.g., 148 Sales Call 1s vs 6 Qualified Leads in January 2024)
  - Suggests calls can occur across multiple stages, multiple calls per deal, or calls unlinked to deals
- Activity tracking provides additional pipeline health metrics beyond stage counts

### Model Limitations

**CRITICAL: Disconnected Activity and Deal Data**
- Only 8 deals (~0.4%) exist in BOTH `deal_changes` and `activity` tables
- Verification query:
```sql
  SELECT COUNT(DISTINCT dc.deal_id) 
  FROM deal_changes dc
  INNER JOIN activity a ON dc.deal_id = a.deal_id;
  -- Result: 8 deals
```
- **What this means:**
  - Stage progression tracks ~2,000 deals
  - Sales Call activities track mostly different deals
  - Sub-steps 2.1 and 3.1 represent total call volume, not calls on the same deals progressing through stages
  - Model combines two largely independent datasets via `UNION ALL`
  
- **Implications for the report:**
  - Main stages (1-9): Track deal progression through pipeline
  - Sales Calls (2.1, 3.1): Track overall call activity volume
  - These are parallel metrics, not integrated (e.g., "Sales Call 1" does not specifically track calls during "Qualified Lead" stage)
  - Report shows "deals at each stage" + "calls made" rather than "calls made on deals at each stage"

- **Possible reasons for this discrepancy:**
  - Test data created independently for different purposes
  - Activity table may include non-deal activities (prospecting, general outreach)
  - Different data sources merged for assessment

- **Production recommendation:**
  - Clarify with stakeholders: Should calls be matched to specific deal stages?
  - Investigate why only 0.4% overlap exists
  - Consider separate reports: "Deal Stage Progression" vs "Sales Activity Volume"
  - Validate if activities without `deal_id` should be included

### Potential Future Enhancements

**Sales Rep Attribution**

- Deals can be reassigned between sales reps (tracked via `user_id` changes in `deal_changes`)
- Current model aggregates deals by stage and month, but does not attribute to specific reps
- Example: Deal 672206 transferred from Kevin Smith to Michael Williams mid-funnel
- Potential extensions:
  - Add `user_id` dimension: `deals_per_stage_per_rep_per_month`
  - Track ownership changes: deals reassigned vs retained
  - Attribution logic: credit deal to creator vs closer
  - Rep performance analysis: conversion rates by salesperson

### Output Schema

| Column | Type | Description |
|--------|------|-------------|
| month | DATE | First day of month |
| kpi_name | TEXT | Funnel step name |
| funnel_step | NUMERIC | Stage number (1-9, 2.1, 3.1) |
| deals_count | INTEGER | Distinct deal count |

### Files Modified
- `models/rep_sales_funnel_monthly.sql`: Main reporting model
- `sources.yml`: Added all source table definitions
- `models/schema.yml`: Model documentation

### Running the Project
```bash
# Start database
docker compose up

# Run dbt model
dbt run

# Results in: public_pipedrive_analytics.rep_sales_funnel_monthly
```

### Appendix: Validation Queries

**Funnel totals across all months:**
```sql
SELECT 
    funnel_step, 
    kpi_name, 
    SUM(deals_count) as total_deals
FROM public_pipedrive_analytics.rep_sales_funnel_monthly 
GROUP BY kpi_name, funnel_step 
ORDER BY funnel_step;
```
