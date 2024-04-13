{{
    config(
        tags=['transformation','fact']
    )
}}

WITH

-- Load userskills table
prep_userSkills AS (
    SELECT
        USER_SKILL_ID,
        USER_ID,
        SKILL_ID,
        CERTIFICATE_ID,
        PROJECT_EXPERIENCE_ID,
        APPROVER_DETAIL_ID,
        PROFICIENCY,
        STATUS as VERIFIED_NOT,
        HACKER_RANK_SCORE
    FROM {{ ref("prep_userskills") }}
),

-- Load approverdetails table
prep_approverdetails AS (
    SELECT
        APPROVER_DETAIL_ID,
        CREATED_AT as APPROVER_CREATED_AT,
        UPDATED_AT as APPROVER_UPDATED_AT
    FROM {{ ref("prep_approverdetails") }}
),

-- Join userskills with approverdetails to calculate decision time
fact_userskills AS (
    SELECT
        us.USER_SKILL_ID,
        us.USER_ID,
        us.SKILL_ID,
        us.CERTIFICATE_ID,
        us.PROJECT_EXPERIENCE_ID,
        us.APPROVER_DETAIL_ID,
        us.PROFICIENCY,
        us.VERIFIED_NOT,
        us.HACKER_RANK_SCORE,
        DATEDIFF(DAY, ad.APPROVER_CREATED_AT, ad.APPROVER_UPDATED_AT) AS DECISION_TIME_DAYS
    FROM prep_userSkills us
    LEFT JOIN prep_approverdetails ad ON us.APPROVER_DETAIL_ID = ad.APPROVER_DETAIL_ID
)

SELECT * FROM fact_userskills
