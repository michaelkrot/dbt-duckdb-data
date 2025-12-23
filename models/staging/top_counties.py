# realistically using python here is overkill, this is more to show this is possible in DBT if you wanted to do maniupulation of a small dataset
def model(dbt, session):
    # Reference the upstream mart model correctly (no Jinja needed)
    upstream_df = dbt.ref("fct_readmissions_clean").df()  # Efficient: returns DuckDB relation, not full pandas yet

    # Push the aggregation to DuckDB SQL (fast, low memory/CPU — only loads ~58 rows)
    sql = """
    SELECT
        county,
        ROUND(AVG(readmission_rate_pct), 4) AS avg_readmission_rate
    FROM upstream_df
    GROUP BY county
    ORDER BY avg_readmission_rate DESC
    """

    # Execute the SQL on the relation (stays in DuckDB until .df())
    result_relation = session.sql(sql)

    # Convert only the small aggregated result to pandas (minimal overhead)
    result_df = result_relation.df()

    return result_df

