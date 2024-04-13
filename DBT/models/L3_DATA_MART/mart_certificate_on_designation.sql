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

dim_certificates AS (
    SELECT
        *
    FROM {{ ref("dim_certificates") }}
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

certificate_counts_with_verified_and_pending AS (
    SELECT
        COALESCE(ucd.DESIGNATION, 'Unknown') AS DESIGNATION,
        COUNT(DISTINCT f.CERTIFICATE_ID) AS TOTAL_CERTIFICATES,
        COUNT(DISTINCT CASE WHEN f.VERIFIED_NOT = 'Verified' THEN f.CERTIFICATE_ID ELSE NULL END) AS VERIFIED_CERTIFICATES,
        COUNT(DISTINCT CASE WHEN f.STATUS = 'Pending' THEN f.CERTIFICATE_ID ELSE NULL END) AS PENDING_CERTIFICATES,
        COUNT(DISTINCT CASE WHEN f.STATUS = 'Rejected' THEN f.CERTIFICATE_ID ELSE NULL END) AS REJECTED_CERTIFICATES,
        (COUNT(DISTINCT CASE WHEN f.VERIFIED_NOT = 'Verified' THEN f.CERTIFICATE_ID ELSE NULL END) * 100.0) / NULLIF(COUNT(DISTINCT f.CERTIFICATE_ID), 0) AS 
        VERIFIED_PERCENTAGE,
        (COUNT(DISTINCT CASE WHEN f.STATUS = 'Rejected' THEN f.CERTIFICATE_ID ELSE NULL END) * 100.0) / NULLIF(COUNT(DISTINCT f.CERTIFICATE_ID), 0) AS REJECTED_PERCENTAGE,
        (COUNT(DISTINCT CASE WHEN f.STATUS = 'Pending' THEN f.CERTIFICATE_ID ELSE NULL END) * 100.0) / NULLIF(COUNT(DISTINCT f.CERTIFICATE_ID), 0) AS PENDING_PERCENTAGE,
        AVG(dc.VALIDITY_PERIOD_MONTHS) AS AVERAGE_VALIDITY_MONTHS
    FROM
        fact_userskills_with_approverdetails f
    LEFT JOIN
        dim_users ucd ON f.DESIGNATION = ucd.DESIGNATION
    LEFT JOIN
        dim_certificates dc ON f.CERTIFICATE_ID = dc.CERTIFICATE_ID
    GROUP BY
        COALESCE(ucd.DESIGNATION, 'Unknown')
)

SELECT 
    ccvp.DESIGNATION,
    ccvp.TOTAL_CERTIFICATES,
    ccvp.VERIFIED_CERTIFICATES,
    ccvp.PENDING_CERTIFICATES,
    ccvp.REJECTED_CERTIFICATES,
    ccvp.VERIFIED_PERCENTAGE,
    ccvp.PENDING_PERCENTAGE,
    ccvp.REJECTED_PERCENTAGE,
    ccvp.AVERAGE_VALIDITY_MONTHS
FROM 
    certificate_counts_with_verified_and_pending ccvp
