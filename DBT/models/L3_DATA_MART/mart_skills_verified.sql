{{
    config(
        tags=['MART']
    )
}}

-- Load userskills table
WITH fact_userskills AS (
    SELECT
        *
    FROM {{ ref("fact_userskills") }}
),

-- Load user table
dim_users AS (
    SELECT
        USER_ID,
        FULL_NAME,
        DESIGNATION
    FROM {{ ref("dim_users") }}
),


dim_approverdetails AS(
    SELECT
        *
    FROM {{ref("dim_approverdetails")}}
),

-- Count verified distinct skills for each user
verified_skills_count AS (
    SELECT
        USER_ID,
        COUNT(DISTINCT SKILL_ID) AS verified_skill_count
    FROM fact_userskills
    WHERE VERIFIED_NOT = 'Verified'
    GROUP BY USER_ID
),

-- Count advanced skills for each user
advanced_skills_count AS (
    SELECT
        USER_ID,
        COUNT(DISTINCT SKILL_ID) AS advanced_skill_count
    FROM fact_userskills
    WHERE VERIFIED_NOT = 'Verified' AND PROFICIENCY = 'advanced'
    GROUP BY USER_ID
),

-- Count intermediate skills for each user
intermediate_skills_count AS (
    SELECT
        USER_ID,
        COUNT(DISTINCT SKILL_ID) AS intermediate_skill_count
    FROM fact_userskills
    WHERE VERIFIED_NOT = 'Verified' AND PROFICIENCY = 'intermediate'
    GROUP BY USER_ID
),

-- Count beginner skills for each user
beginner_skills_count AS (
    SELECT
        USER_ID,
        COUNT(DISTINCT SKILL_ID) AS beginner_skill_count
    FROM fact_userskills
    WHERE VERIFIED_NOT = 'Verified' AND PROFICIENCY = 'beginner'
    GROUP BY USER_ID
),

-- Calculate average hacker rank score for verified skills for each user
average_hacker_rank_score AS (
    SELECT
        USER_ID,
        AVG(HACKER_RANK_SCORE) AS average_hacker_rank_score_verified
    FROM fact_userskills
    WHERE VERIFIED_NOT = 'Verified'
    GROUP BY USER_ID
),

-- Calculate average decision time for verified skills for each user
average_decision_time AS (
    SELECT
        USER_ID,
        AVG(DECISION_TIME_DAYS) AS average_decision_time_verified
    FROM fact_userskills
    WHERE VERIFIED_NOT = 'Verified'
    GROUP BY USER_ID
),

-- Load approverdetails table and calculate average rating for approved records
average_rating_approved AS (
    SELECT
        USER_ID,
        AVG(RATING) AS average_rating_approved
    FROM dim_approverdetails
    WHERE STATUS = 'Approved'
    GROUP BY USER_ID
),

-- Final SELECT statement
final_results AS (
    SELECT 
        u.USER_ID,
        u.FULL_NAME,
        u.DESIGNATION,
        COALESCE(vsc.verified_skill_count, 0) AS verified_skill_count,
        COALESCE(asc.advanced_skill_count, 0) AS advanced_skill_count,
        COALESCE(isc.intermediate_skill_count, 0) AS intermediate_skill_count,
        COALESCE(bsc.beginner_skill_count, 0) AS beginner_skill_count,
        COALESCE(ahrs.average_hacker_rank_score_verified, 0) AS average_hacker_rank_score_verified,
        COALESCE(adt.average_decision_time_verified, 0) AS average_decision_time_verified,
        COALESCE(ara.average_rating_approved, 0) AS average_rating_approved
    FROM dim_users u
    LEFT JOIN verified_skills_count vsc ON u.USER_ID = vsc.USER_ID
    LEFT JOIN advanced_skills_count asc ON u.USER_ID = asc.USER_ID
    LEFT JOIN intermediate_skills_count isc ON u.USER_ID = isc.USER_ID
    LEFT JOIN beginner_skills_count bsc ON u.USER_ID = bsc.USER_ID
    LEFT JOIN average_hacker_rank_score ahrs ON u.USER_ID = ahrs.USER_ID
    LEFT JOIN average_decision_time adt ON u.USER_ID = adt.USER_ID
    LEFT JOIN average_rating_approved ara ON u.USER_ID = ara.USER_ID
)

-- Output the final results
SELECT * FROM final_results ORDER BY verified_skill_count DESC
