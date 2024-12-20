SELECT *
FROM {{ source('pipedrive','deal_changes') }}