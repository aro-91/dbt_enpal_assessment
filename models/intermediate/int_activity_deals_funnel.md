{% docs int_activity_deals_funnel %}

#### Sources

We use below tables as input source from the intermediate layer

1. `private_pipedrive_analytics.int_deal_stage_progression`
2. `private_pipedrive_analytics.int_activity_funnel_mapping`

#### Model: int_activity_deals_funnel

This model combines the above two models so that end users can do a `deal_id` level analysis and see how various `deal_id`s progress and filter out any deal_ids of interest. This model gives flexibility of a more granular analysis

{% enddocs %}