
      update "postgres"."public_staging"."sn_users"
    set dbt_valid_to = DBT_INTERNAL_SOURCE.dbt_valid_to
    from "sn_users__dbt_tmp102530822891" as DBT_INTERNAL_SOURCE
    where DBT_INTERNAL_SOURCE.dbt_scd_id::text = "postgres"."public_staging"."sn_users".dbt_scd_id::text
      and DBT_INTERNAL_SOURCE.dbt_change_type::text in ('update'::text, 'delete'::text)
      and "postgres"."public_staging"."sn_users".dbt_valid_to is null;

    insert into "postgres"."public_staging"."sn_users" ("id", "name", "email", "modified", "dbt_updated_at", "dbt_valid_from", "dbt_valid_to", "dbt_scd_id")
    select DBT_INTERNAL_SOURCE."id",DBT_INTERNAL_SOURCE."name",DBT_INTERNAL_SOURCE."email",DBT_INTERNAL_SOURCE."modified",DBT_INTERNAL_SOURCE."dbt_updated_at",DBT_INTERNAL_SOURCE."dbt_valid_from",DBT_INTERNAL_SOURCE."dbt_valid_to",DBT_INTERNAL_SOURCE."dbt_scd_id"
    from "sn_users__dbt_tmp102530822891" as DBT_INTERNAL_SOURCE
    where DBT_INTERNAL_SOURCE.dbt_change_type::text = 'insert'::text;

  