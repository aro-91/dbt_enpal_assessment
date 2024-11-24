{% snapshot sn_users %}  

{{
  config(      
    target_schema='public_staging',      
    strategy='timestamp',      
    unique_key='id',      
    updated_at='modified',
    invalidate_hard_deletes=True       
  )  
}}

SELECT * 
FROM {{ source('postgres_public','users') }}

{% endsnapshot %}