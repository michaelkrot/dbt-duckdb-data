# realistically using pandas here is overkill, this is more to show this is possible in DBT
def model(dbt, session):
    # Load the dbt model as a Pandas DataFrame
    df = dbt.ref("fct_readmissions_clean").to_df()  # <- fixed from .to_pandas()

    # Convert string percentages to float
    df["readmission_rate_pct"] = (
        df["readmission_rate_pct"]
        .astype(float)
        / 100
    )

    # Group by county and calculate average readmission rate
    result = (
        df.groupby("county", as_index=False)
        .agg(avg_readmission_rate=("readmission_rate_pct", "mean"))
    )

    result = result.sort_values("avg_readmission_rate", ascending=False)

    return result

