begin;
    insert into pipedrive_analytics.intermediate.int_deal_stage_history ("DEAL_STAGE_CHANGE_ID", "DEAL_ID", "STAGE_ID", "STAGE_NAME", "VALID_FROM", "VALID_TO")
    (
        select "DEAL_STAGE_CHANGE_ID", "DEAL_ID", "STAGE_ID", "STAGE_NAME", "VALID_FROM", "VALID_TO"
        from pipedrive_analytics.intermediate.int_deal_stage_history__dbt_tmp
    )

;
    commit;