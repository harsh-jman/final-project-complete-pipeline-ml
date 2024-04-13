{{ config(
    tags=['prep']
) }}

WITH required_fields_cast AS (
    SELECT
        CAST("_id" AS VARCHAR) AS PROJECT_EXPERIENCE_ID,
        CAST("userId" AS VARCHAR) AS USER_ID,
        CAST("projectName" AS VARCHAR) AS PROJECT_NAME,
        CAST("description" AS VARCHAR) AS DESCRIPTION,
        TO_TIMESTAMP("startDate", 'YYYY-MM-DD"T"HH24:MI:SS.FF6Z') AS START_DATE,
        TO_TIMESTAMP("endDate", 'YYYY-MM-DD"T"HH24:MI:SS.FF6Z') AS END_DATE,
        CAST("supportedDocumentLink" AS VARCHAR) AS SUPPORTED_DOCUMENT_LINK
    FROM
        {{ source('SnowFlakeDB', 'PROJECTEXPERIENCES') }}
)

SELECT * FROM required_fields_cast
