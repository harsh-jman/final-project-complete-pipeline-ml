{{
    config(
        tags=['MART']
    )
}}

-- Load user table
WITH dim_users AS (
    SELECT
        USER_ID,
        FULL_NAME,
        DESIGNATION
    FROM {{ ref("dim_users") }}
),

-- Load approval details table
dim_approval_details AS (
    SELECT
        USER_ID,
        STATUS
    FROM {{ ref("dim_approverdetails") }}
),

-- Load fact table
fact_userskills AS (
    SELECT
        USER_ID,
        APPROVER_DETAIL_ID
    FROM {{ ref("fact_userskills") }}
),

-- Right join fact and users
fact_users_right_join_users AS (
    SELECT
        COALESCE(fu.USER_ID, du.USER_ID) AS USER_ID,
        COALESCE(ad.STATUS, 'No Skill') AS STATUS
    FROM dim_users du
    LEFT JOIN fact_userskills fu ON du.USER_ID = fu.USER_ID
    LEFT JOIN dim_approval_details ad ON du.USER_ID = ad.USER_ID
),

-- Count different statuses for non-skill users
non_skill_user_status_counts AS (
    SELECT
        fu.USER_ID,
        SUM(CASE WHEN fu.STATUS = 'Approved' THEN 1 ELSE 0 END) AS total_approved_skills,
        SUM(CASE WHEN fu.STATUS = 'Rejected' THEN 1 ELSE 0 END) AS total_rejected_skills,
        SUM(CASE WHEN fu.STATUS = 'Pending' THEN 1 ELSE 0 END) AS total_pending_skills
    FROM fact_users_right_join_users fu
    WHERE fu.STATUS != 'No Skill'
    GROUP BY fu.USER_ID
)

-- Final output: User ID, counts for each status category
SELECT
    du.USER_ID,
    du.FULL_NAME,
    du.DESIGNATION,
    COALESCE(nsu.total_approved_skills, 0) AS total_approved_skills,
    COALESCE(nsu.total_rejected_skills, 0) AS total_rejected_skills,
    COALESCE(nsu.total_pending_skills, 0) AS total_pending_skills
FROM
    dim_users du
LEFT JOIN
    non_skill_user_status_counts nsu ON du.USER_ID = nsu.USER_ID
ORDER BY
    du.USER_ID