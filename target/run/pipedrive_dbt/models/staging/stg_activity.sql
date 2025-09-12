begin;
    insert into pipedrive_analytics.staging.stg_activity ("ACTIVITY_ID", "ACTIVITY_TYPE", "ASSIGNED_TO_USER_ID", "DEAL_ID", "IS_DONE", "DUE_TO_TIMESTAMP", "RN")
    (
        select "ACTIVITY_ID", "ACTIVITY_TYPE", "ASSIGNED_TO_USER_ID", "DEAL_ID", "IS_DONE", "DUE_TO_TIMESTAMP", "RN"
        from pipedrive_analytics.staging.stg_activity__dbt_tmp
    )

;
    commit;