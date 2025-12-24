# California Hospital Readmission Analytics with dbt + DuckDB

**End-to-end data engineering pipeline** on real-world, messy public health data (2011–2023).

Demonstrates:
- Cleaning challenging data (string percentages, suppressed `*` values, ICD-9 → ICD-10 transition)
- Production-grade dbt practices (macros, layered testing, custom generic tests)
- Delivery of actionable insights via interactive dashboard

## Why This Project?
This project showcases core data engineering skills on a real dataset with common real-world issues:
- Percentage strings (`"14%"`) requiring parsing
- Schema changes over time (ICD-9 to ICD-10 transition)
- Demographic and payer stratification

The result is a clean, tested analytical mart powering an interactive Streamlit dashboard for exploring readmission disparities by county, year, insurance, age, and race/ethnicity.

## Tech Stack
- **dbt Core** – transformation & testing
- **DuckDB** – lightweight analytical database
- **Streamlit + Plotly** – interactive visualization
- **Python/pandas** – preprocessing & optional Python models
- **Docker** – reproducible environment

## Data Source
Public dataset from California Health and Human Services:  
[All-Cause Unplanned 30-Day Hospital Readmission Rate, California](https://data.chhs.ca.gov/dataset/all-cause-unplanned-30-day-hospital-readmission-rate-california)

Raw CSV requires preprocessing (BOM, whitespace, line endings). A script generates the clean seed used by dbt.

## Quick Start (Docker Recommended)

### Recommended: One-Command Full Demo
Experience the complete pipeline — no local setup required!

```bash
git clone https://github.com/michaelkrot/dbt-duckdb-data.git
cd dbt-duckdb-data
docker build -t dbt-duckdb-data .

# Dashboard + Lineage (recommended for reviewers)
docker run -it -p 8501:8501 -p 8080:8080 -v $(pwd):/app -w /app --cpus="4.0" dbt-duckdb-data both
```

Then open:

Interactive Dashboard: http://localhost:8501
dbt Lineage & Documentation: http://localhost:8080

The -v $(pwd):/app mount enables live code edits and persistent DuckDB data.

### Individual Modes

```bash
# Lineage & docs only
docker run -it -p 8080:8080 -v $(pwd):/app -w /app dbt-duckdb-data docs

# Dashboard only
docker run -it -p 8501:8501 -v $(pwd):/app -w /app dbt-duckdb-data dashboard
```

## Local Devlpment (Optional)
```bash
pip install -r requirements.txt

# Create ~/.dbt/profiles.yml (gitignored)
cat > ~/.dbt/profiles.yml << EOF
duckdb_dbt_project:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: data/dev_duckdb.db
      threads: 4
EOF

dbt deps
dbt build

# Dashboard
streamlit run dashboards/app.py

# Lineage
dbt docs generate
dbt docs serve```

## Key Features

###Data Quality & Testing

Production-grade rigor with layered dbt tests:

not_null on key dimensions
Year range validation (2011–2023)
Uniqueness on natural business key
Custom generic testvalid_readmission_rate — reusable validation for decimal rates (handles ICD transition nulls)

All tests pass: 
```bash
dbt test
```

## Technical Decisions & Lessons Learned

- COALESCE for ICD-9/ICD-10 unification — gracefully handles transition, prefers newer standard
- Early filtering of suppressed values — shift-left quality to prevent propagation
- Custom macroconvert_pct — parsing of percentage strings
- Data quality incidents caught by tests — commas in counts, nulls from suppression — fixed with cast/replace and strict filtering
- Performance tuning — DuckDB threads limited to 4; snapshots disabled for static data (duckDB has having issues)
- If I did this again — incremental marts, multi-page Streamlit navigation, GitHub Actions CI, probably different data with a more interesting story


## Data Preparation

Raw file preserved in seeds/raw/ (ignored by dbt and not in git).  Assumes file location at: seeds/raw/allcauseunplanned30-dayhospitalreadmissionratecalifornia2011_2023.csv

Clean seed generated reproducibly:

```bash 
python analyses/prep_seed_data.py
dbt seed --full-refresh
```

## Known Limitations
- dbt-duckdb does not support all_varchar for seeds
- Explicit column_types used as a workaround

## Future Improvements
- Incremental materialization for larger datasets
- CI with GitHub Actions (dbt test on push)
- Multi-page Streamlit dashboard
- Migration to cloud warehouse (Snowflake/BigQuery)
- pull in some text data to stock the DuckDB for a RAG implementation