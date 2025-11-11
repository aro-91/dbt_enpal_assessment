{% macro stage_to_step(stage_id) %}
    case {{ stage_id }}
        when '1' then 'Step 1: Lead Generation'
        when '2' then 'Step 2: Qualified Lead'
        when '3' then 'Step 3: Needs Assessment'
        when '4' then 'Step 4: Proposal/Quote Preparation'
        when '5' then 'Step 5: Negotiation'
        when '6' then 'Step 6: Closing'
        when '7' then 'Step 7: Implementation/Onboarding'
        when '8' then 'Step 8: Follow-up/Customer Success'
        when '9' then 'Step 9: Renewal/Expansion'
        else null
    end
{% endmacro %}
