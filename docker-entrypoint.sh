#!/usr/bin/env bash
set -e

echo "=== Starting dbt-duckdb-data container ==="

# Create reproducible dbt profile inside container (no local ~/.dbt needed)
mkdir -p /root/.dbt
cat > /root/.dbt/profiles.yml << EOF
duckdb_dbt_project:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: /app/data/dev_duckdb.db
      threads: 4
    prod:
      type: duckdb
      path: /app/data/prod_duckdb.db
      threads: 4
EOF

export DBT_PROFILES_DIR=/root/.dbt
echo "✓ dbt profile created and DBT_PROFILES_DIR set"

# Install dbt packages
echo "Installing dbt dependencies..."
dbt deps

# Use DBT_TARGET env var if set, default to dev
TARGET=${DBT_TARGET:-dev}
echo "Using target: $TARGET"

# Mode selection
if [ "$1" = "docs" ]; then
    echo "=== Mode: dbt docs only ==="
    dbt build --target "$TARGET"
    dbt docs generate --empty-catalog
    echo "Serving dbt docs on http://localhost:8080"
    exec dbt docs serve --port 8080 --host 0.0.0.0

elif [ "$1" = "dashboard" ]; then
    echo "=== Mode: Streamlit dashboard only ==="
    dbt build --target "$TARGET"
    echo "Launching dashboard on http://localhost:8501"
    exec streamlit run dashboards/top_counties_viz.py --server.port=8501 --server.address=0.0.0.0

elif [ "$1" = "both" ]; then
    echo "=== Mode: BOTH dbt docs + Streamlit dashboard ==="
    dbt build --target "$TARGET"
    dbt docs generate --empty-catalog

    echo "Starting dbt docs in background[](http://localhost:8080)"
    dbt docs serve --port 8080 --host 0.0.0.0 &

    echo "Launching Streamlit dashboard in foreground[](http://localhost:8501)"
    exec streamlit run dashboards/top_counties_viz.py --server.port=8501 --server.address=0.0.0.0

else
    echo "=== Default: running dbt command ==="
    if [ $# -eq 0 ]; then
        dbt build --target "$TARGET"
    else
        dbt "$@" --target "$TARGET"
    fi
fi
