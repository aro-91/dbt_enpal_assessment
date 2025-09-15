{% docs rep_sales_funnel_monthly %}

#### Sources

We use below tables as input source from the intermediate layer

1. `private_pipedrive_analytics.int_activity_deals_funnel`
2. `private_pipedrive_analytics.int_month_funnel_matrix`

#### Model: rep_sales_funnel_monthly

This model is a reporting layer model which calculates the total deals at different funnel stages in a given year-month.

{% enddocs %}