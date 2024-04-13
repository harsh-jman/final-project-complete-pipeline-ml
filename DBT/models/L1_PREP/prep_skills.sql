{{ config(
    tags=['prep']
) }}

WITH required_fields_cast AS (
    SELECT
        CAST("_id" AS VARCHAR) AS SKILL_ID,
        CAST("skillName" AS VARCHAR) AS SKILL_NAME,
        CAST("description" AS VARCHAR) AS DESCRIPTION,
        CASE 
            WHEN "createdAt" IS NOT NULL THEN TO_TIMESTAMP("createdAt", 'YYYY-MM-DD HH24:MI:SS.FF3')
            ELSE NULL 
        END AS CREATED_AT,
        CASE 
            WHEN "updatedAt" IS NOT NULL THEN TO_TIMESTAMP("updatedAt", 'YYYY-MM-DD HH24:MI:SS.FF3')
            ELSE NULL 
        END AS UPDATED_AT,
    FROM
        {{ source('SnowFlakeDB', 'SKILLS') }}
)

SELECT * FROM required_fields_cast
