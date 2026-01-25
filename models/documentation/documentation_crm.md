{% docs activity_id %}
Unique identifier of the activity.
{% enddocs %}

{% docs assigned_user_id %}
User ID of the person assigned to the activity.
{% enddocs %}

{% docs change_id %}
A unique id for every deal change. A newly created unique identifier.
{% enddocs %}

{% docs deal_id %}
Deal id in the CRM. 
{% enddocs %}

{% docs is_done %}
Boolean flag indicating whether the activity is completed.
{% enddocs %}

{% docs due_to_at %}
Datetime when the activity is due.
{% enddocs %}

{% docs activity_type %}
Type of the activity (e.g., call, meeting, email).
{% enddocs %}

{% docs activity_type_name %}
Name of the activity type.
{% enddocs %}

{% docs activity_type_category %}
Category of the activity type.
{% enddocs %}

{% docs is_active %}
Boolean flag to show activity type is active or not.
{% enddocs %}

{% docs activity_type_id %}
Id of the activity type. 
{% enddocs %}

{% docs change_time %}
Datetime when the deal change occurred.
{% enddocs %}

{% docs changed_field_key %}
Field key that was modified in the deal.
{% enddocs %}

{% docs new_value %}
New value after the field was changed.
{% enddocs %}

{% docs field_key %}
Unique identifier key of the field.
{% enddocs %}

{% docs field_value_options %}
Available value options for the field.
{% enddocs %}

{% docs field_id %}
Id of the field. 
{% enddocs %}

{% docs field_name %}
Name of the field.
{% enddocs %}

{% docs label_id %}
Label identifier for the field.
{% enddocs %}

{% docs label_value %}
Name of the label.
{% enddocs %}

{% docs stage_id %}
Unique identifier of the stage.
{% enddocs %}

{% docs stage_name %}
Name of the stage.
{% enddocs %}

{% docs stage_start_time %}
Start time of the stage.
{% enddocs %}

{% docs stage_end_time %}
End time of the stage.
{% enddocs %}

{% docs user_id %}
Unique identifier of the user.
{% enddocs %}

{% docs user_email %}
Email of the user.
{% enddocs %}

{% docs user_name %}
Name of the user.
{% enddocs %}

{% docs modified_at %}
Datetime when the user record was last modified.
{% enddocs %}

{% docs month_name %}
Month name of the reporting month.
{% enddocs %}

{% docs kpi_name %}
Name of the funnel kpi.
Example values include 'Lead Generation', 'Qualified Lead','Sales Call 1', 'Needs Assessment', 'Sales Call 2','Proposal/Quote Preparation', 'Negotiation', 'Closing','Implementation/Onboarding', 'Follow-up/Customer Success','Renewal/Expansion'.
{% enddocs %}

{% docs funnel_step %}
Stage id/funnel&stage of the CRM process identifier.
Based on stage_id from deals or activity funnel mapping.
Also includes the sub steps 2.1 and 3.1 based on the call activities.
{% enddocs %}

{% docs deals_count %}
Number of distinct deals (deal_id) that reached the funnel step during the reporting month.
{% enddocs %}

{% docs is_lost_deal %}
Flag that tells whether the stage is lost_reason or not
{% enddocs %}

{% docs stage_duration_in_days %}
Represent how long the deal was in this stage
{% enddocs %}