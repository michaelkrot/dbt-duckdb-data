"""
Preprocessing script for California hospital readmissions data.

Purpose:
  Convert raw downloaded CSV to clean, dbt-seed-ready file.
  - Handles BOM encoding
  - Strips whitespace from columns and string values
  - Ensures consistent line endings
  - Preserves raw file untouched

Usage:
  python analyses/prep_seed_data.py

Input:  seeds/raw/allcause_unplanned_30day_original.csv
Output: seeds/health_data/readmissions_seed.csv
"""

import pandas as pd
from pathlib import Path

def clean_readmissions_data():
    """Clean raw readmissions CSV for reliable dbt seed ingestion."""
    
    # Define paths
    project_root = Path(__file__).parent.parent  # analyses/ -> project root
    raw_path = project_root / "raw_data/allcauseunplanned30-dayhospitalreadmissionratecalifornia2011_2023.csv"
    output_path = project_root / "seeds/health_data/readmissions_seed.csv"
    
    # Validate input exists
    if not raw_path.exists():
        raise FileNotFoundError(f"Raw file not found: {raw_path}\nDownload from source and place in seeds/raw/")
    
    print(f"Reading raw data from: {raw_path}")
    df = pd.read_csv(raw_path, encoding='utf-8-sig')
    original_rows, original_cols = df.shape
    
    # Clean column names
    df.columns = df.columns.str.strip()
    
    # Clean string values
    str_cols = df.select_dtypes(include=['object']).columns
    df[str_cols] = df[str_cols].apply(lambda x: x.str.strip() if x.dtype == "object" else x)
    
    # Ensure output directory
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Write clean CSV (Unix line endings, no index)
    df.to_csv(output_path, index=False, lineterminator='\n')
    
    print(f"✓ Cleaned data written to: {output_path}")
    print(f"  Rows: {original_rows:,} → {len(df):,}")
    print(f"  Columns: {original_cols} → {len(df.columns)}")
    print(f"  String columns cleaned: {len(str_cols)}")

if __name__ == "__main__":
    clean_readmissions_data()
