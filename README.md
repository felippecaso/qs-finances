# QS-MDS: Quantified Self Modern Data Stack

A personal finance data pipeline built with the Modern Data Stack, extracting transaction data from multiple Brazilian financial institutions and processing it through a Meltano-based ELT pipeline with dbt transformations.

## Overview

This project follows an **ELT (Extract, Load, Transform)** architecture:
1. **Extract**: Multiple tap extractors pull data from various financial institutions
2. **Load**: Data is loaded into DuckDB and/or CSV files via Meltano targets  
3. **Transform**: dbt handles data modeling and transformations
4. **Visualize**: Rill provides interactive dashboards

## Quick Start

### Prerequisites
- Python 3.9+
- pip/pipx
- AWS credentials (for S3 data sources)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd qs-finances
   ```

2. **Install Meltano and dependencies**
   ```bash
   make build
   # OR
   meltano install
   ```

3. **Set up environment variables** (see [Environment Variables](#environment-variables) section)

4. **Run the pipeline**
   ```bash
   # Load data to DuckDB
   meltano run load-finances-to-duckdb
   
   # OR load data to CSV/Parquet files
   meltano run load-finances-to-csv
   
   # Run dbt transformations
   meltano invoke dbt-duckdb:run
   ```

## Environment Variables

Create a `.env` file in the project root with the following variables:

### Required Environment Variables

```bash
# Meltano Core
MELTANO_PROJECT_ROOT=/path/to/your/project
MELTANO_ENVIRONMENT=dev

# dbt Configuration
DBT_DUCKDB_PATH=/path/to/your/project/data/catalog/qsmds.duckdb

# AWS S3 Access (for financial data sources)
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_DEFAULT_REGION=us-east-1

# BTG Pactual (for encrypted files)
TAP_BTG_FILE_PASSWORD=your-btg-file-password
```

### Optional Environment Variables

```bash
# For different environments
MELTANO_ENVIRONMENT=prod  # Use 'prod' for production

# Custom S3 configurations (if using different bucket)
S3_BUCKET_NAME=your-custom-bucket  # Default: felippe-data
```

## Data Sources

The pipeline extracts data from multiple Brazilian financial institutions:

### S3-Based Sources
All raw files are stored in `s3://felippe-data/raw/` with institution-specific folders:

- **Nubank**: `s3://felippe-data/raw/nubank/*.csv`
- **Itaú**: `s3://felippe-data/raw/itau/*.csv` 
- **C6 Bank**: `s3://felippe-data/raw/c6/*.csv`
- **Banco do Brasil**: `s3://felippe-data/raw/bb/*.csv` (latin1 encoding)
- **Alelo**: `s3://felippe-data/raw/alelo/*.csv`
- **Caju**: `s3://felippe-data/raw/caju/*.csv`

### Custom API Sources
- **BTG Pactual**: Custom tap (`tap-btg`) for investments, banking, and credit transactions
- **Nomad**: Custom tap (`tap-nomad`) for international transactions

## Project Structure

```
qs-finances/
├── .env                          # Environment variables (create this)
├── meltano.yml                   # Main pipeline configuration
├── Makefile                      # Build and utility commands
├── WARP.md                       # Development guidance
├── data/
│   ├── input/                    # Input configuration files
│   │   ├── finances_categories.csv  # Transaction categories
│   │   └── private/              # Private data files (not tracked)
│   ├── catalog/                  # Output directory (DuckDB + exports)
│   └── raw/                      # Raw data files (local, not tracked)
├── transform/                    # dbt project
│   ├── dbt_project.yml          # dbt configuration
│   ├── models/                   # dbt models
│   ├── macros/                   # Custom dbt macros
│   └── profiles/                 # dbt profiles
├── notebook/                     # Jupyter notebooks for exploration
└── .devcontainer/               # VS Code dev container config
```

## Data Pipeline Commands

### Core Pipeline Operations
```bash
# Load all financial data to DuckDB
meltano run load-finances-to-duckdb

# Load all financial data to CSV/Parquet files
meltano run load-finances-to-csv

# Run dbt transformations
meltano invoke dbt-duckdb:run

# Test dbt models
meltano invoke dbt-duckdb:test

# Generate dbt documentation
meltano invoke dbt-duckdb:docs generate
```

### Individual Source Extraction
```bash
# Extract from specific sources
meltano run tap-csv-nubank nubank_transactions_mapper target-duckdb
meltano run tap-btg btg_mapper target-duckdb
meltano run tap-csv-itau itau_transactions_mapper target-duckdb
meltano run tap-csv-caju caju_transactions_mapper target-duckdb
meltano run tap-csv-alelo alelo_transactions_mapper target-duckdb
meltano run tap-csv-bb bb_transactions_mapper target-duckdb
meltano run tap-csv-c6 c6_transactions_mapper target-duckdb
meltano run tap-nomad nomad_transactions_mapper target-duckdb
```

## Development Environment

### Jupyter Lab
```bash
# Start Jupyter Lab for data exploration
meltano invoke jupyterlab:launch
```

### Data Visualization with Rill
```bash
# Install, build and run Rill for interactive dashboards
make rill-visuals

# Individual steps
make rill-install  # Install Rill CLI
make rill-build    # Build Rill project with data sources
make rill-run      # Start Rill server
```

### VS Code DevContainer
The project includes a complete development container:
- Python 3.9 with Meltano pre-installed
- dbt and SQL extensions configured
- File associations for `.sql` files as `jinja-sql`

## Data Schema

### Transaction Categories
The system uses a predefined category structure (`data/input/finances_categories.csv`):
- **Income**: Salary, dividends, side projects, etc.
- **Fixed Expenses**: Rent, utilities, subscriptions, etc.
- **Variable Expenses**: Shopping, travel, entertainment, etc.
- **Investments**: Applications, withdrawals, taxes, etc.

### Automated Processing
- **Date Parsing**: Handles multiple date formats across institutions
- **Data Cleaning**: Filters out balance entries and internal transfers  
- **Field Mapping**: Standardizes field names across all sources
- **Export Automation**: Auto-generates CSV and Parquet files from dbt models

## Scheduled Operations

The project includes a weekly scheduled job:
```yaml
# Runs every week automatically
weekly-finances-load: load-finances-to-csv
```

## Configuration Files

### Required Setup Files
1. **Categories**: Edit `data/input/finances_categories.csv` for your expense categories
2. **Private Data**: Add manual transaction files to `data/input/private/`
3. **dbt Profile**: Create `.meltano/dbt_profile/profiles.yml` for VS Code dbt extension

## Troubleshooting

### Common Issues

1. **AWS S3 Access Denied**
   - Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set
   - Ensure AWS user has S3 read permissions for the data bucket

2. **BTG Files Not Loading**
   - Check `TAP_BTG_FILE_PASSWORD` is correctly set for encrypted files

3. **dbt VS Code Extension Issues**
   - Create `.meltano/dbt_profile/profiles.yml` without environment variables
   - Note: Querying may not work due to env var dependency

4. **DuckDB Connection Issues**
   - Verify `DBT_DUCKDB_PATH` points to the correct database file
   - Ensure `MELTANO_PROJECT_ROOT` is set to the project directory

