### 1. Project Structure
```
── models/
│   
├── staging/
│   │   |   ├── raw_source.yml
│   │   │   ├── stg_model.yml
│   │   │   ├── stg_activities.sql
│   │   │   ├── stg_activity_types.sql
│   │   │   ├── stg_deal_changes.sql
│   │   │   ├── stg_deal_stages.sql
│   │   │   ├── stg_monthly_spine.sql
│   │   │   └── stg_users.sql
│   ├── intermediate/
│   │   |   ├── intermediate_model.yml
│   │   │   ├── intermediate_deals_stages.sql
│   └── marts/
│       |   ├── mart_model.yml
│       │   ├── report_deal_funnel_analysis.sql
├── macros/
│   ├── generate_schema.sql
├── analysis/
│   ├── Source_data_exploration.md
├── Lineage/
│   ├── dbt_pipedrive_funnelanalysis.jpeg
```

### Materialization Strategy

1. Staging schema is created with stage views 
2. Intermediate layer is also materialized with views
3. Mart layer is materialized as tables with added index 

In Future based on performance and load we can update the strategy with incremental load. Currently there is no need for this analysis
### Report Data Design - Thought Process

Design Justification: I have created a monthly spine to support the continuous data and filling the missing funnels

#### 1. Ensures Data Consistency and Integrity
By explicitly creating rows for every month and every funnel step, the final table's structure is always consistent. This prevents data gaps and makes the output predictable for any downstream tool, such as a BI dashboard. It guarantees a reliable foundation for all reporting.

#### 2. Enables Accurate and Trustworthy Reporting
A complete data set is essential for accurate trend analysis. If a funnel step is missing for a particular month, it can lead to distorted visualizations and misinterpretations. This design ensures all steps are represented, allowing for clear and trustworthy month-over-month comparisons.

#### 3. "Zero" is a Meaningful sometime
The absence of a row can be ambiguous. By explicitly including rows with a deals_count of 0, the model provides a clear and valuable business insight: "zero deals reached this funnel step this month." This removes ambiguity and gives sales managers a clear signal on where a specific part of the funnel might be underperforming.

#### 4. Simplifies Downstream Logic
This pre-modeled approach offloads complexity from end-users. Analysts and BI tools can query the final table directly without needing to write complex LEFT JOIN or COALESCE statements to fill in missing values. The data is pre-processed and ready for immediate consumption.

