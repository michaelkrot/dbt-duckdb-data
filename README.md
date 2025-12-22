## Why This Project?
- Demonstrates end-to-end data engineering on **messy real-world data** (string percentages, suppressed values '*', ICD-9/ICD-10 transition)
- Handles common challenges: defensive parsing, early data filtering, reusable custom macros
- Produces healthcare disparities insights (e.g., by county, demographics, payer)
- Includes an **interactive Streamlit dashboard** for exploration

## Key Features & Recent Updates
- **Staging layer**: Basic cleaning and source definition
- **Custom macro** (`convert_pct`): Reusable logic for parsing percentage strings
- **Clean mart** (`fct_readmissions_clean`): Unified numeric rates, early suppression filtering, macro reuse for consistency
- **Interactive dashboard**: Top counties, year-over-year trends, filters by year/strata
- Data quality: Excludes suppressed low-volume data for reliable analytics

## Tech Stack
- dbt Core
- DuckDB (lightweight analytics database)
- Streamlit + Plotly (interactive visualization)
- Python (dashboard)

## Data Source
Public dataset from California Health and Human Services Open Data Portal:  
[All-Cause Unplanned 30-Day Hospital Readmission Rate](https://data.chhs.ca.gov/dataset/all-cause-unplanned-30-day-hospital-readmission-rate-california)

https://healthdata.gov/State/All-Cause-Unplanned-30-Day-Hospital-Readmission-Ra/mikx-ck6c/about_data

I had to clean up the newlines/carriage returns:
```bash
sed -i '' -e 's/[[:space:]]*$//' -e 's/\r//g' seeds/health_data/allcauseunplanned30_dayhospitalreadmissionratecalifornia2011_2023.csv
```
I also to manually had to delete spaces at the end of the original data columns.  Why were there? ```¯\_(ツ)_/¯```

## Quick Start
```bash
git clone https://github.com/michaelkrot/dbt-duckdb-data.git
cd dbt-duckdb-data

# Install dependencies
pip install dbt-duckdb streamlit plotly duckdb

# Build the pipeline (loads seed, runs models/tests)
dbt build

# View data lineage & documentation
dbt docs generate
dbt docs serve


##To Run the dahsboard
dbt build  # Ensure latest data
streamlit run dashboards/app.py



## Known Limitations
- dbt-duckdb does not support all_varchar for seeds
- Explicit column_types used as a workaround


## Future Improvements
- Add incremental models for large datasets
- Add CI with dbt test on pull requests
- Move from DuckDB to Snowflake/BigQuery for scale

## Seed Data and Model Dependencies

This project includes a CSV seed file (`readmissions_seed.csv`) containing California hospital readmission data. The seed is loaded into the `raw` schema using:

```bash
dbt seed --full-refresh
```



## Notes for later 

Running prod target in docker:

docker run -e DBT_TARGET=prod dbt-duckdb → runs dbt build --target prod

Dev is default like so:
docker run dbt-duckdb → runs dbt build --target dev (default)

To run with in docker persistent duckdb database locally (outside of docker):

docker run --rm  -v /tmp/foobar:/app/data  -e DBT_TARGET=prod  dbt-duckdb

Writes to local /tmp/foobar directory for docker.

This is not ideal (writing to desktop), but wanted to play around with moving the duckdb around in later work for further analysis/viz/mcp server stuff.
