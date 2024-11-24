{% snapshot sn_activities %}  

{{
  config(      
    target_schema='public_staging',      
    strategy='check',      
    unique_key=['activity_id','deal_id','due_to'],      
    check_cols=['done'],
    invalidate_hard_deletes=True 
  )  
}}

SELECT * 
FROM {{ source('postgres_public','activity') }}

{% endsnapshot %}