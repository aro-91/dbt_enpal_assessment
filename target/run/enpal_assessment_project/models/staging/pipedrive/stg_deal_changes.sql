
      
        
            delete from "postgres"."public_staging"."stg_deal_changes"
            using "stg_deal_changes__dbt_tmp102614016764"
            where (
                
                    "stg_deal_changes__dbt_tmp102614016764".deal_id = "postgres"."public_staging"."stg_deal_changes".deal_id
                    and 
                
                    "stg_deal_changes__dbt_tmp102614016764".change_time = "postgres"."public_staging"."stg_deal_changes".change_time
                    and 
                
                    "stg_deal_changes__dbt_tmp102614016764".changed_field_key = "postgres"."public_staging"."stg_deal_changes".changed_field_key
                    
                
                
            );
        
    

    insert into "postgres"."public_staging"."stg_deal_changes" ("deal_id", "change_time", "changed_field_key", "new_value")
    (
        select "deal_id", "change_time", "changed_field_key", "new_value"
        from "stg_deal_changes__dbt_tmp102614016764"
    )
  