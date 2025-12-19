## Project Overview
This project models California hospital readmission data using dbt + DuckDB.

## Design Principles
- Raw data preserved as-is in seeds
- All type coercion happens in staging models
- Percent fields stored as strings in raw, parsed in models

## Advanced Features

- **Snapshots:** Track historical trends in readmission rates.
- **Macros:** Reusable SQL functions, e.g., converting percentages to decimal values.
- **Analyses:** Exploration queries for insights, without creating permanent tables.

This demonstrates best practices for dbt projects and shows readiness for real-world data engineering tasks.  Admittedly, this is a pretty small example.


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

Seed data was downloaded from:
https://healthdata.gov/State/All-Cause-Unplanned-30-Day-Hospital-Readmission-Ra/mikx-ck6c/about_data

I had to clean up the newlines/carriage returns:
```bash
sed -i '' -e 's/[[:space:]]*$//' -e 's/\r//g' seeds/health_data/allcauseunplanned30_dayhospitalreadmissionratecalifornia2011_2023.csv
```

I also to manually had to delete spaces at the end of the original data columns.  Why were there? ```¯\_(ツ)_/¯```

## General notes for reference while working (clean up later)
To run locally:

dbt build --full-refresh


To run in docker:

docker build -t dbt-duckdb .
docker run dbt-duckdb run 






To run with persistent duckdb database for later:

docker run -e DBT_TARGET=prod dbt-duckdb → runs dbt build --target prod

docker run dbt-duckdb → runs dbt build --target dev (default)

docker run dbt-duckdb run --models my_model → runs dbt run --models my_model --target dev (or prod if env var set)

docker run --rm   -v $(pwd)/data:/app/data  dbt-duckdb run

docker run --rm  -v /Users/michaelkrot/Desktop:/app/data  -e DBT_TARGET=prod  dbt-duckdb

 dbt build --full-refresh
