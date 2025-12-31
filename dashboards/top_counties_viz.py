import streamlit as st
import duckdb
import pandas as pd
import plotly.express as px

# Page config
st.set_page_config(page_title="CA Hospital Readmissions", layout="wide")
st.title("California 30-Day Hospital Readmissions Dashboard")
st.markdown("Built with **dbt + DuckDB** → Clean data in `fct_readmissions_clean`")

# Create DuckDB connection (POINT THIS TO YOUR DB FILE)
con = duckdb.connect("data/dev_duckdb.db", read_only=True)

# Load data (cached)
@st.cache_data(ttl=3600)
def load_data():
    return con.execute(
        "SELECT * FROM dev_duckdb.fct_readmissions_clean"
    ).df()

df = load_data()

# Sidebar filters
st.sidebar.header("Filters")

years = st.sidebar.multiselect(
    "Year",
    options=sorted(df['year'].unique()),
    default=sorted(df['year'].unique())
)

all_strata_options = sorted(df['strata'].unique())

# Prioritize common lowercase variant
overall_candidates = ['All ages', 'All Ages', 'All', 'Overall']
default_strata = next(
    (c for c in overall_candidates if c in all_strata_options),
    all_strata_options[0]
)

selected_strata = st.sidebar.multiselect(
    "Strata (Demographic/Payer Breakdown)",
    options=all_strata_options,
    default=[default_strata]
)

st.sidebar.caption("Examples: 'All ages' = statewide overall, 'Medicare' = payer-specific, '65+' = age group")

# Temporary debug — remove after confirming
st.sidebar.write("Debug: Strata values")
st.sidebar.write(all_strata_options)

# Filter data
filtered = df[df['year'].isin(years) & df['strata'].isin(selected_strata)]

# Top counties overall
st.subheader("Top 15 Counties by Average Readmission Rate (%)")
top_counties = (
    filtered.groupby('county')['readmission_rate_pct']
    .mean()
    .round(2)
    .sort_values(ascending=False)
    .head(15)
    .reset_index()
)

col1, col2 = st.columns([3, 1])
with col1:
    fig = px.bar(
        top_counties,
        x='county',
        y='readmission_rate_pct',
        color='readmission_rate_pct',
        color_continuous_scale='Reds',
        title="Average Rate by County"
    )
    fig.update_layout(xaxis_title="", yaxis_title="Rate (%)", showlegend=False)
    st.plotly_chart(fig, use_container_width=True)

with col2:
    st.dataframe(top_counties, hide_index=True, use_container_width=True)

# Year-over-year trend
st.subheader("Year-over-Year Trend (Selected Strata)")
trend = (
    filtered.groupby('year')['readmission_rate_pct']
    .mean()
    .round(2)
    .reset_index()
)

fig_trend = px.line(
    trend,
    x='year',
    y='readmission_rate_pct',
    markers=True,
    title="Statewide Average Rate Over Time"
)
fig_trend.update_layout(yaxis_title="Rate (%)")
st.plotly_chart(fig_trend, use_container_width=True)

# Footer
st.caption("Data source: California Health and Human Services Open Data Portal | Pipeline: dbt + DuckDB")