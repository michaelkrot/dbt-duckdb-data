#!/usr/bin/env bash
set -e

# Install dependencies
dbt deps

# Use DBT_TARGET environment variable if set, default to dev
TARGET=${DBT_TARGET:-dev}

# Special mode: "docs" to generate and serve interactive lineage/docs
if [ "$1" = "docs" ]; then
    echo "Building project and generating dbt docs..."
    dbt build --target "$TARGET"  # Ensures latest manifest with tests/models/snapshots
    dbt docs generate
    echo "Serving dbt docs (interactive lineage graph) on http://localhost:8080"
    echo "Open in your browser and explore the DAG, tests, and model details!"
    exec dbt docs serve --port 8080 --host 0.0.0.0
else
    # Original behavior: if no args, default to dbt build; otherwise pass args through
    if [ $# -eq 0 ]; then
        dbt build --target "$TARGET"
    else
        dbt "$@" --target "$TARGET"
    fi
fi
