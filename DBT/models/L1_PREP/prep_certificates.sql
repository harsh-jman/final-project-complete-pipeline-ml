{{ config(
    tags=['prep']
) }}

WITH required_fields_cast AS (
  SELECT
        CAST("_id" AS VARCHAR) AS CERTIFICATE_ID,
        CAST("userId" AS VARCHAR) AS USER_ID,
        CAST("certificateId" AS INT) AS CERTIFICATE_ID_NUM,
        CAST("certificateName" AS VARCHAR) AS CERTIFICATE_NAME,
        CAST("description" AS VARCHAR) AS DESCRIPTION,
        CAST("issuingAuthority" AS VARCHAR) AS ISSUING_AUTHORITY,
        TO_TIMESTAMP("issueDate", 'YYYY-MM-DD"T"HH24:MI:SS.FF6Z') AS ISSUE_DATE,
        CAST("validityPeriodMonths" AS INT) AS VALIDITY_PERIOD_MONTHS,
        CAST("supportedDocumentLink" AS VARCHAR) AS SUPPORTED_DOCUMENT_LINK,
        TO_TIMESTAMP("createdAt", 'YYYY-MM-DD"T"HH24:MI:SS.FF6Z') AS CREATED_AT,
        TO_TIMESTAMP("updatedAt", 'YYYY-MM-DD"T"HH24:MI:SS.FF6Z') AS UPDATED_AT,
    FROM
        {{ source('SnowFlakeDB', 'CERTIFICATES') }}
)

SELECT * FROM required_fields_cast
