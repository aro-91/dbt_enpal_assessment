SELECT *
FROM {{ source('postgres_public','stages') }}
