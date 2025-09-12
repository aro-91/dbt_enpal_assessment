begin;
    insert into pipedrive_analytics.staging.stg_deal_changes ("DEAL_ID", "CHANGE_TIMESTAMP", "CHANGED_FIELD_KEY", "NEW_VALUE")
    (
        select "DEAL_ID", "CHANGE_TIMESTAMP", "CHANGED_FIELD_KEY", "NEW_VALUE"
        from pipedrive_analytics.staging.stg_deal_changes__dbt_tmp
    )

;
    commit;