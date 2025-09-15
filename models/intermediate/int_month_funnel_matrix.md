{% docs int_month_funnel_matrix %}

#### Sources

We use below tables as input source from the intermediate layer

1. `private_pipedrive_analytics.int_activity_deals_funnel`

#### Model: int_month_funnel_matrix

This model is a helper table and derives all the possible combination of `month_year` and `funnel_step`. This model ensure that the final report has a given `funnel_step` even if we have no deal id corresponding to it. The count for particular funnel step is indicated as 0

{% enddocs %}