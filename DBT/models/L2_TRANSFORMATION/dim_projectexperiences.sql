{{
    config(
        tags=['transformation','dim']
    )
}}

WITH

prep_projectexperiences AS (

    SELECT
        PROJECT_EXPERIENCE_ID,
        USER_ID,
        PROJECT_NAME,
        START_DATE,
        END_DATE

    FROM {{ ref("prep_projectexperiences") }}
),

prep_projectexperiences_total_days AS (
    
    SELECT
    
    *,
    DATEDIFF(DAY, START_DATE, END_DATE) + 1 AS TOTAL_NO_OF_DAYS_IN_PROJECT

    FROM prep_projectexperiences
)

SELECT * FROM prep_projectexperiences_total_days
