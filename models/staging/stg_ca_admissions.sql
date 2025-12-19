-- models/staging/stg_ca_admissions.sql
SELECT
    "Year" AS year,
    "Strata" AS strata,
    "Strata Name" AS strata_name,
    "County" AS county,
    "Total Admits (ICD-9)" AS total_admits_icd9,
    "30-day Readmits (ICD-9)" AS readmits_30_day_icd9,
    {{ convert_pct('"30-day Readmission Rate (ICD-9)"') }} AS readmission_rate_30_day_icd9,
    "Total Admits (ICD-10)" AS total_admits_icd10,
    "30-day Readmits (ICD-10)" AS readmits_30_day_icd10,
    {{ convert_pct('"30-day Readmission Rate (ICD-10)"') }} AS readmission_rate_30_day_icd10
FROM {{ ref('readmissions_seed') }}

