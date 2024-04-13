{{
    config(
        tags=['MART']
    )
}}

WITH

dim_users AS (
    SELECT
        *
    FROM {{ ref("dim_users") }}
),

dim_approverdetails AS (
    SELECT
        *
    FROM {{ ref("dim_approverdetails") }}
),

dim_projectexperience AS (
    SELECT
        *
    FROM {{ ref("dim_projectexperiences") }}
),

fact_userskills_with_users AS (
    SELECT
        f.*,
        u.DESIGNATION
    FROM
        {{ ref("fact_userskills") }} f
    LEFT JOIN
        dim_users u ON u.USER_ID = f.USER_ID
),

fact_userskills_with_approverdetails AS (
    SELECT
        f.*,
        ad.STATUS
    FROM
        fact_userskills_with_users f
    LEFT JOIN
        dim_approverdetails ad ON ad.APPROVER_DETAIL_ID = f.APPROVER_DETAIL_ID
),

project_experience_counts_with_verified_and_pending AS (
    SELECT
        COALESCE(ucd.DESIGNATION, 'Unknown') AS DESIGNATION,
        COUNT(DISTINCT f.PROJECT_EXPERIENCE_ID) AS TOTAL_PROJECT_EXPERIENCES,
        COUNT(DISTINCT CASE WHEN f.STATUS = 'Pending' THEN f.PROJECT_EXPERIENCE_ID ELSE NULL END) AS PENDING_PROJECT_EXPERIENCES,
        COUNT(DISTINCT CASE WHEN f.STATUS = 'Rejected' THEN f.PROJECT_EXPERIENCE_ID ELSE NULL END) AS REJECTED_PROJECT_EXPERIENCES,
        COUNT(DISTINCT CASE WHEN f.VERIFIED_NOT = 'Verified' THEN f.PROJECT_EXPERIENCE_ID ELSE NULL END) AS VERIFIED_PROJECT_EXPERIENCES,
        AVG(DISTINCT pe.TOTAL_NO_OF_DAYS_IN_PROJECT) AS AVERAGE_DAYS_IN_PROJECT,
        (COUNT(DISTINCT CASE WHEN f.STATUS = 'Pending' THEN f.PROJECT_EXPERIENCE_ID ELSE NULL END) * 100.0) / NULLIF(COUNT(DISTINCT f.PROJECT_EXPERIENCE_ID), 0) AS PENDING_PERCENTAGE,
        (COUNT(DISTINCT CASE WHEN f.STATUS = 'Rejected' THEN f.PROJECT_EXPERIENCE_ID ELSE NULL END) * 100.0) / NULLIF(COUNT(DISTINCT f.PROJECT_EXPERIENCE_ID), 0) AS REJECTED_PERCENTAGE,
        (COUNT(DISTINCT CASE WHEN f.VERIFIED_NOT = 'Verified' THEN f.PROJECT_EXPERIENCE_ID ELSE NULL END) * 100.0) / NULLIF(COUNT(DISTINCT f.PROJECT_EXPERIENCE_ID), 0) AS VERIFIED_PERCENTAGE
    FROM
        fact_userskills_with_approverdetails f
    LEFT JOIN
        dim_users ucd ON f.DESIGNATION = ucd.DESIGNATION
    LEFT JOIN
        dim_projectexperience pe ON f.PROJECT_EXPERIENCE_ID = pe.PROJECT_EXPERIENCE_ID
    GROUP BY
        COALESCE(ucd.DESIGNATION, 'Unknown')
)

SELECT 
    pcvp.DESIGNATION,
    pcvp.TOTAL_PROJECT_EXPERIENCES,
    pcvp.PENDING_PROJECT_EXPERIENCES,
    pcvp.REJECTED_PROJECT_EXPERIENCES,
    pcvp.VERIFIED_PROJECT_EXPERIENCES,
    pcvp.PENDING_PERCENTAGE,
    pcvp.REJECTED_PERCENTAGE,
    pcvp.VERIFIED_PERCENTAGE,
    pcvp.AVERAGE_DAYS_IN_PROJECT
FROM 
    project_experience_counts_with_verified_and_pending pcvp
