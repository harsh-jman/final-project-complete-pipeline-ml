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

user_counts_by_designation AS (
    SELECT
        DESIGNATION,
        COUNT(*) AS USER_COUNT,
        SUM(CASE WHEN ROLE = 'admin' THEN 1 ELSE 0 END) AS ADMIN_COUNT
    FROM
        dim_users
    GROUP BY
        DESIGNATION
)

SELECT * FROM user_counts_by_designation

-- users count on designation and admin counts