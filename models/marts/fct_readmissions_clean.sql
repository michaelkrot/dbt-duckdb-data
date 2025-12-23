-- models/marts/core/fct_readmissions_clean.sql
-- Using existing convert_pct macro with defensive handling for '*'

{{ config(materialized='table') }}

WITH source AS (
    SELECT *
    FROM {{ ref('stg_ca_admissions') }}
),

filtered AS (
    SELECT *
    FROM source
    WHERE 
        (CAST(readmission_rate_30_day_icd10 AS VARCHAR) NOT IN ('*', '') 
         OR CAST(readmission_rate_30_day_icd9 AS VARCHAR) NOT IN ('*', ''))
),

cleaned AS (
    SELECT
        county,
        year,
        strata,

        -- Reuse your convert_pct macro safely:
        -- First strip '*', then apply macro (which strips '%' and /100)
        -- Multiply by 100 to keep as percentage (14.5 instead of 0.145)
        COALESCE(
            {{ convert_pct("REPLACE(CAST(readmission_rate_30_day_icd10 AS VARCHAR), '*', '')") }} * 100,
            {{ convert_pct("REPLACE(CAST(readmission_rate_30_day_icd9 AS VARCHAR), '*', '')") }} * 100
        ) AS readmission_rate_pct,

        -- Integer fields — safe parsing
        COALESCE(
            TRY_CAST(REPLACE(CAST(readmits_30_day_icd10 AS VARCHAR), '*', '') AS INTEGER),
            TRY_CAST(REPLACE(CAST(readmits_30_day_icd9 AS VARCHAR), '*', '') AS INTEGER)
        ) AS readmits_count,

        COALESCE(
            TRY_CAST(CAST(total_admits_icd10 AS VARCHAR) AS INTEGER),
            TRY_CAST(CAST(total_admits_icd9 AS VARCHAR) AS INTEGER)
        ) AS total_admissions

    FROM filtered
)

SELECT *
FROM cleaned
WHERE readmission_rate_pct IS NOT NULL