{{
    config(
        tags=['transformation','dim']
    )
}}

WITH

prep_certificates AS (

    SELECT
    
        CERTIFICATE_ID,
        USER_ID,
        CERTIFICATE_ID_NUM,
        ISSUING_AUTHORITY,
        ISSUE_DATE,
        VALIDITY_PERIOD_MONTHS

    FROM {{ ref("prep_certificates") }}
)

SELECT * FROM prep_certificates
