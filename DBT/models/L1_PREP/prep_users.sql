{{ config(
    tags=['prep']
) }}

WITH required_fields_cast AS (
    SELECT
        CAST("_id" AS VARCHAR) AS USER_ID,
        CAST("firstName" AS VARCHAR) AS FIRST_NAME,
        CAST("lastName" AS VARCHAR) AS LAST_NAME,
        CAST("email" AS VARCHAR) AS EMAIL,
        CAST("role" AS VARCHAR) AS ROLE,
        CAST("forcePasswordReset" AS BOOLEAN) AS FORCE_PASSWORD_RESET,
        CAST("isActive" AS BOOLEAN) AS IS_ACTIVE,
        CAST("designation" AS VARCHAR) AS DESIGNATION,
        CASE WHEN "updatedAt" = '' THEN NULL ELSE TO_TIMESTAMP("updatedAt", 'YYYY-MM-DD HH24:MI:SS.FF3') END AS UPDATED_AT,
        CASE WHEN "createdAt" = '' THEN NULL ELSE TO_TIMESTAMP("createdAt", 'YYYY-MM-DD HH24:MI:SS.FF3') END AS CREATED_AT,
    FROM
        {{ source('SnowFlakeDB', 'USERS') }}
)

SELECT * FROM required_fields_cast
