{{ config(materialized='table') }}

select
  county,
  year,
  strata,
  strata_name,

  -- Unified readmission rate (already cleaned decimal from macro, no comma issue)
  coalesce(readmission_rate_30_day_icd10, readmission_rate_30_day_icd9) as readmission_rate_pct,

  -- Unified readmission count (clean commas + safe cast to int)
  coalesce(
    try_cast(replace(readmits_30_day_icd10, ',', '') as int),
    try_cast(replace(readmits_30_day_icd9, ',', '') as int)
  ) as readmits_count,

  -- Unified total admissions (same cleaning)
  coalesce(
    try_cast(replace(total_admits_icd10, ',', '') as int),
    try_cast(replace(total_admits_icd9, ',', '') as int)
  ) as total_admissions,

  -- Preserve originals for transparency
  readmission_rate_30_day_icd9,
  readmission_rate_30_day_icd10,
  readmits_30_day_icd9,
  readmits_30_day_icd10,
  total_admits_icd9,
  total_admits_icd10

from {{ ref('stg_ca_admissions') }}
where
  -- Filter using the cleaned/unified values
  coalesce(
    try_cast(replace(readmits_30_day_icd10, ',', '') as int),
    try_cast(replace(readmits_30_day_icd9, ',', '') as int)
  ) is not null
  and coalesce(
    try_cast(replace(readmits_30_day_icd10, ',', '') as int),
    try_cast(replace(readmits_30_day_icd9, ',', '') as int)
  ) >= 0

  and coalesce(
    try_cast(replace(total_admits_icd10, ',', '') as int),
    try_cast(replace(total_admits_icd9, ',', '') as int)
  ) is not null
  and coalesce(
    try_cast(replace(total_admits_icd10, ',', '') as int),
    try_cast(replace(total_admits_icd9, ',', '') as int)
  ) > 0

  and coalesce(readmission_rate_30_day_icd10, readmission_rate_30_day_icd9) is not null
  and coalesce(readmission_rate_30_day_icd10, readmission_rate_30_day_icd9) >= 0