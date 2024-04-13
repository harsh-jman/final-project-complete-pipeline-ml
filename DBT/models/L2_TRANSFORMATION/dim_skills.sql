{{
    config(
        tags=['transformation','dim']
    )
}}

WITH

prep_skills AS (

    SELECT

    SKILL_ID,
    SKILL_NAME,
    CREATED_AT,
    UPDATED_AT

    FROM {{ ref("prep_skills") }}
)

SELECT * FROM prep_skills
