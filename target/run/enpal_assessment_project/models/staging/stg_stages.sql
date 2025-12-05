
  
    

  create  table "postgres"."public_public"."stg_stages__dbt_tmp"
  
  
    as
  
  (
    with source as (

    select * from "postgres"."public"."stages"

),

renamed as (

    select

        stage_id::integer as stage_id,
        stage_name::varchar(255) as stage_name
        
    from source

)

select * from renamed
  );
  