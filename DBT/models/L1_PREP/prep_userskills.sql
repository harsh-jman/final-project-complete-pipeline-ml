{{ config(
    tags=['prep']
) }}

WITH required_fields_cast AS (
  SELECT
        CAST("_id" AS VARCHAR) AS USER_SKILL_ID,
        CAST("userId" AS VARCHAR) AS USER_ID,
        CAST("skillId" AS VARCHAR) AS SKILL_ID,
        CASE WHEN "certificateId" IS NOT NULL THEN CAST("certificateId" AS VARCHAR) ELSE NULL END AS CERTIFICATE_ID,
        CAST("proficiency" AS VARCHAR) AS PROFICIENCY,
        CAST("status" AS VARCHAR) AS STATUS,
        CAST("hackerRankScore" AS INT) AS HACKER_RANK_SCORE,
        TO_TIMESTAMP("createdAt", 'YYYY-MM-DD"T"HH24:MI:SS.FF3Z') AS CREATED_AT,
        TO_TIMESTAMP("updatedAt", 'YYYY-MM-DD"T"HH24:MI:SS.FF3Z') AS UPDATED_AT,
        CASE WHEN "projectExperienceId" IS NOT NULL THEN CAST("projectExperienceId" AS VARCHAR) ELSE NULL END AS PROJECT_EXPERIENCE_ID,
        CAST("approverDetailId" AS VARCHAR) AS APPROVER_DETAIL_ID
    FROM
        {{ source('SnowFlakeDB', 'USERSKILLS') }}
)

SELECT * FROM required_fields_cast
