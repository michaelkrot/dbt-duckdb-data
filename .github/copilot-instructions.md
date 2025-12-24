# GitHub Copilot Instructions for dbt-duckdb-data Project

This repository is a **data engineering portfolio project** demonstrating **dbt best practices** on real-world data using **dbt and DuckDB**.  
Copilot should prioritize **production-like, readable, and well-tested code** over brevity or cleverness.

---

## General Guidelines
- Follow **dbt best practices**: layered models (staging → marts), reusable macros, comprehensive tests.
- Use **snake_case** for all identifiers (models, columns, files).
- Prioritize **readability and documentation**:
  - Add comments for complex or non-obvious logic
  - Add descriptions in YAML files for all models and columns
- Focus on **data quality**:
  - Suggest tests for `not_null`, `unique`, accepted ranges, and validity checks where appropriate
  - Prefer generic tests when reusable

---

## Project Structure
- `models/staging/`: Cleaning and parsing
  - Handle percentage strings, suppressed values (`*`), and type coercion defensively
- `models/marts/`: Analytical models
  - Unified metrics (e.g., `COALESCE` for ICD-9 / ICD-10)
  - Consumer-facing guarantees enforced via tests
- `macros/`: Reusable Jinja logic
  - Example: `convert_pct` for percentage parsing
- `tests/`: Generic and singular tests
  - Example: custom `valid_readmission_rate`
- `dashboards/`: Streamlit app for interactive visualization
- `seeds/`: Clean CSV seeds
  - Raw files live in `seeds/raw/` and are excluded from dbt runs

---

## Coding Style
- **SQL**
  - Use consistent indentation
  - Use CTEs for complex logic
  - Use meaningful aliases
- **Tests**
  - Prefer generic tests when reusable
  - Use `dbt_utils` where applicable
- **Python (Streamlit / models)**
  - Use type hints
  - Descriptive variable names
  - Use `@st.cache_data` for expensive queries
- **Comments**
  - Explain **why**, not just **what**, especially for data filtering or assumptions

---

## Default Expectations
- When generating new dbt models:
  - Include a corresponding YAML file
  - Add column descriptions
  - Add relevant tests for primary keys and critical metrics
- Prefer explicit, readable SQL over compact one-liners
- Optimize for clarity and maintainability

---

## Key Concepts to Reinforce
- Handle suppressed values (`*`) and parsing issues defensively
- Use `COALESCE` for graceful ICD-9 → ICD-10 unification
- Layer tests:
  - Raw validation in staging
  - Consumer guarantees in marts
- Performance considerations:
  - Limit DuckDB threads to 4
  - Avoid snapshots on static data

---

## Do Not Suggest
- Hardcoded paths or credentials
- Materializing staging models as tables (prefer views)
- Committing `profiles.yml` or DuckDB database files

---

Thank you for helping maintain high-quality, production-like code in this portfolio project!
