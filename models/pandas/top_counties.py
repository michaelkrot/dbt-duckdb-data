# models/pandas/top_counties.py
import pandas as pd


# realistically using pandas here is overkill, this is more to show this is possible in DBT
def model(dbt, session):
    # Load the dbt model as a Pandas DataFrame
    df = dbt.ref("stg_ca_admissions").to_df()  # <- fixed from .to_pandas()

    # Convert string percentages to float
    df["readmission_rate_30_day_icd9"] = (
        df["readmission_rate_30_day_icd9"]
        .astype(float)
        / 100
    )

    # Group by county and calculate average readmission rate
    result = (
        df.groupby("county", as_index=False)
        .agg(avg_readmission_rate=("readmission_rate_30_day_icd9", "mean"))
    )

    result = result.sort_values("avg_readmission_rate", ascending=False)

    return result

