
To run:

docker build -t dbt-duckdb .
docker run dbt-duckdb run 


Seed data was downloaded from:
https://healthdata.gov/State/All-Cause-Unplanned-30-Day-Hospital-Readmission-Ra/mikx-ck6c/about_data

had to clean up the newlines/carriage returns:
sed -i '' -e 's/[[:space:]]*$//' -e 's/\r//g' seeds/health_data/allcauseunplanned30_dayhospitalreadmissionratecalifornia2011_2023.csv

also had to delete newlines at the end of the columns


To run with persistent duckdb database for later:

docker run -e DBT_TARGET=prod dbt-duckdb → runs dbt build --target prod

docker run dbt-duckdb → runs dbt build --target dev (default)

docker run dbt-duckdb run --models my_model → runs dbt run --models my_model --target dev (or prod if env var set)

docker run --rm   -v $(pwd)/data:/app/data  dbt-duckdb run
docker run --rm  -v /Users/michaelkrot:/app/data  -e DBT_TARGET=prod  dbt-duckdb dbt build --full-refresh
