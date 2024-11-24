
      update "postgres"."public_staging"."sn_activities"
    set dbt_valid_to = DBT_INTERNAL_SOURCE.dbt_valid_to
    from "sn_activities__dbt_tmp102530671733" as DBT_INTERNAL_SOURCE
    where DBT_INTERNAL_SOURCE.dbt_scd_id::text = "postgres"."public_staging"."sn_activities".dbt_scd_id::text
      and DBT_INTERNAL_SOURCE.dbt_change_type::text in ('update'::text, 'delete'::text)
      and "postgres"."public_staging"."sn_activities".dbt_valid_to is null;

    insert into "postgres"."public_staging"."sn_activities" ("activity_id", "type", "assigned_to_user", "deal_id", "done", "due_to", "dbt_updated_at", "dbt_valid_from", "dbt_valid_to", "dbt_scd_id")
    select DBT_INTERNAL_SOURCE."activity_id",DBT_INTERNAL_SOURCE."type",DBT_INTERNAL_SOURCE."assigned_to_user",DBT_INTERNAL_SOURCE."deal_id",DBT_INTERNAL_SOURCE."done",DBT_INTERNAL_SOURCE."due_to",DBT_INTERNAL_SOURCE."dbt_updated_at",DBT_INTERNAL_SOURCE."dbt_valid_from",DBT_INTERNAL_SOURCE."dbt_valid_to",DBT_INTERNAL_SOURCE."dbt_scd_id"
    from "sn_activities__dbt_tmp102530671733" as DBT_INTERNAL_SOURCE
    where DBT_INTERNAL_SOURCE.dbt_change_type::text = 'insert'::text;

  