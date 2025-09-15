{% docs int_deal_stage_progression %}

#### Sources

We use below tables as input source from the raw layer

1. `private_pipedrive_analytics.raw_fact_deal_changes`
2. `private_pipedrive_analytics.raw_dim_stages`

#### Model: int_deal_stage_progression

This model enriches the deal_changes dataset. It filters the base data only for `stage_id` changes and further derives columns like previous_stage, next_stage etc.

This enriched dataset can be used for granular deal level analysis

{% enddocs %}