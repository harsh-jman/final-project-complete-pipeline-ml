{{ config(
    tags=['prep']
) }}

WITH required_fields_cast AS (
    SELECT
        "_id" AS APPROVER_DETAIL_ID,
        "userId" AS USER_ID,
        "approverUserId" AS APPROVER_USER_ID,
        "userSkillId" AS USER_SKILL_ID,
        "status" AS STATUS,
        TO_TIMESTAMP("createdAt", 'YYYY-MM-DD"T"HH24:MI:SS.FF6Z') AS CREATED_AT,
        TO_TIMESTAMP("updatedAt", 'YYYY-MM-DD"T"HH24:MI:SS.FF6Z') AS UPDATED_AT,
        CASE WHEN "comments" IS NOT NULL THEN "comments" ELSE NULL END AS COMMENTS,
        TRY_CAST("rating" AS FLOAT) AS RATING -- Try to cast rating to FLOAT
    FROM
        {{ source('SnowFlakeDB', 'APPROVERDETAILS') }}
)

SELECT * FROM required_fields_cast
