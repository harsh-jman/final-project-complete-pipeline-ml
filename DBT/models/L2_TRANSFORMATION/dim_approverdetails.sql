{{
    config(
        tags=['transformation','dim']
    )
}}

WITH

prep_approverdetails AS (

    SELECT

        APPROVER_DETAIL_ID,
        USER_ID,
        APPROVER_USER_ID,
        STATUS,
        RATING,
        CREATED_AT,
        UPDATED_AT

    FROM {{ ref('prep_approverdetails') }}
),

prep_approverdetails_duration AS (
    
    SELECT

        *,
        DATEDIFF(DAY, CREATED_AT, UPDATED_AT) AS DECISION_TIME_DAY
    
    FROM prep_approverdetails

)

SELECT * FROM prep_approverdetails_duration
