#!/usr/bin/env bash
set -e

# Install dependencies
dbt deps

# Use DBT_TARGET environment variable if set, default to dev
TARGET=${DBT_TARGET:-dev}

# If no dbt command is provided, default to build
if [ $# -eq 0 ]; then
    dbt build --target "$TARGET"
else
    # Pass the target to any command that supports it
    dbt "$@" --target "$TARGET"
fi
