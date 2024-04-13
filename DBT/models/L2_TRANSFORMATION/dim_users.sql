{{
    config(
        tags=['transformation','dim']
    )
}}

WITH

prep_users AS (

    SELECT

    *

    FROM {{ ref("prep_users") }}
),

prep_users_full_name AS (
    SELECT
        *,
        "FIRST_NAME" || ' ' || "LAST_NAME" AS FULL_NAME
    FROM
        prep_users
),

prep_users_without_names AS (
    SELECT
        USER_ID,
        FULL_NAME,
        EMAIL,
        ROLE,
        DESIGNATION
        
    FROM
        prep_users_full_name
)



SELECT * FROM prep_users_without_names