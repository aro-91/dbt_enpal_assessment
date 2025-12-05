
  
    

  create  table "postgres"."public_public"."stg_user__dbt_tmp"
  
  
    as
  
  (
    with source as (

    select * from "postgres"."public"."users"

),

renamed as (

    select

        id::integer as user_id,
        name::varchar(255) as user_name,
        email::varchar(255) as user_email,
        modified::timestamp as modified_at
        
    from source

)

select * from renamed
  );
  