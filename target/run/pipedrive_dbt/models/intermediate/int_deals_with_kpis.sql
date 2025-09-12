begin;
    insert into pipedrive_analytics.intermediate.int_deals_with_kpis ("DEAL_STAGE_CHANGE_ID", "DEAL_ID", "STAGE_ID", "STAGE_NAME", "VALID_FROM", "FUNNEL_STEP", "FUNNEL_SUB_STEP")
    (
        select "DEAL_STAGE_CHANGE_ID", "DEAL_ID", "STAGE_ID", "STAGE_NAME", "VALID_FROM", "FUNNEL_STEP", "FUNNEL_SUB_STEP"
        from pipedrive_analytics.intermediate.int_deals_with_kpis__dbt_tmp
    )

;
    commit;