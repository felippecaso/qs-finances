# QS-MDS: Quantified Self Modern Data Stack

A personal finance data pipeline built with the Modern Data Stack, extracting transaction data from multiple Brazilian financial institutions and processing it through a Meltano-based ELT pipeline with dbt transformations.

## Overview

This project follows an **ELT (Extract, Load, Transform)** architecture:
1. **Extract**: Multiple tap extractors pull data from various financial institutions
2. **Load**: Data is loaded into DuckDB and/or CSV files via Meltano targets  
3. **Transform**: dbt handles data modeling and transformations
4. **Visualize**: Rill provides interactive dashboards

## Environment Management

The project supports two environments with different database backends:

- **dev** (default): Uses local DuckDB file (`./data/catalog/qsmds.duckdb`)
- **prod**: Uses MotherDuck cloud database (`md:qsmds`)

### Environment Selection

```bash
# Check current environment (defaults to 'dev')
uv run meltano config meltano environment

# Set environment for current session
export MELTANO_ENVIRONMENT=dev    # Development (local DuckDB)
export MELTANO_ENVIRONMENT=prod   # Production (MotherDuck)

# Or specify environment per command
uv run meltano --environment=dev run load-finances-to-duckdb
uv run meltano --environment=prod run load-finances-to-duckdb
```

## Quick Start

### Prerequisites
- **Python 3.13+** (required for latest dependencies)
- **uv** (fast Python package manager) - [Install uv](https://docs.astral.sh/uv/getting-started/installation/)
- AWS credentials (for S3 data sources)
- Git
- **For production**: MotherDuck account and token

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd qs-finances
   ```

2. **Install dependencies with uv**
   ```bash
   # Install all Python dependencies
   uv sync
   
   # Install Meltano plugins
   make build
   # OR manually:
   uv run meltano install
   ```

3. **Set up environment variables** (see [Environment Variables](#environment-variables) section)

4. **Run the pipeline**
   ```bash
   # Load data to DuckDB
   uv run meltano run load-finances-to-duckdb
   # OR use make target:
   make load-to-duckdb
   
   # Load data to CSV/Parquet files
   uv run meltano run load-finances-to-csv
   # OR use make target:
   make load-to-csv
   
   # Run dbt transformations
   uv run meltano invoke dbt-duckdb:run
   # OR use make target:
   make dbt-run
   ```

## Environment Variables

Create a `.env` file in the project root with the following variables:

### Required Environment Variables

```bash
# Meltano Core
MELTANO_PROJECT_ROOT=/path/to/your/project
MELTANO_ENVIRONMENT=dev  # or 'prod' for production

# AWS S3 Access (for financial data sources)
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_DEFAULT_REGION=us-east-1

# BTG Pactual (for encrypted files)
TAP_BTG_FILE_PASSWORD=your-btg-file-password

# MotherDuck (required for prod environment)
MOTHERDUCK_TOKEN=your-motherduck-token  # Get from https://motherduck.com/
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
├── .env.example                  # Environment variables template
├── pyproject.toml                # Modern Python project configuration
├── meltano.yml                   # Main pipeline configuration
├── Makefile                      # Build and utility commands (uv-based)
├── WARP.md                       # Development guidance
├── .venv/                        # Virtual environment (created by uv)
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
└── .devcontainer/               # VS Code dev container config
```

## Modern Development Workflow

This project uses **uv** for fast, reliable Python package management and **make** targets for common operations.

### Available Make Targets

```bash
# Environment setup
make build          # Install Python deps and Meltano plugins
make dev-install    # Install with development dependencies

# Code quality
make format         # Format code with black and ruff
make lint           # Lint code with ruff and mypy
make test           # Run tests with pytest
make test-cov       # Run tests with coverage

# Pipeline operations
make load-to-duckdb # Load all data to DuckDB
make load-to-csv    # Load all data to CSV/Parquet
make dbt-run        # Run dbt transformations
make dbt-test       # Test dbt models
make dbt-docs       # Generate dbt documentation

# Visualization
make rill-visuals   # Install, build and run Rill
```

### Development Dependencies

Install additional development tools:
```bash
# Install development dependencies (linting, testing, formatting)
make dev-install

# Format your code
make format

# Run linting
make lint
```

## Data Pipeline Commands

### Development Environment (Local DuckDB)
```bash
# Load all financial data to local DuckDB (default environment)
uv run meltano run load-finances-to-duckdb
# OR: make load-to-duckdb

# Load all financial data to CSV/Parquet files
uv run meltano run load-finances-to-csv
# OR: make load-to-csv

# Run dbt transformations on local database
uv run meltano invoke dbt-duckdb:run
# OR: make dbt-run

# Test dbt models
uv run meltano invoke dbt-duckdb:test
# OR: make dbt-test
```

### Production Environment (MotherDuck)
```bash
# Load all financial data to MotherDuck (requires MOTHERDUCK_TOKEN)
export MELTANO_ENVIRONMENT=prod
uv run meltano run load-finances-to-duckdb

# Run dbt transformations on MotherDuck
uv run meltano --environment=prod invoke dbt-duckdb:run

# Test dbt models on MotherDuck
uv run meltano --environment=prod invoke dbt-duckdb:test

# Generate dbt documentation
uv run meltano invoke dbt-duckdb:docs generate
# OR: make dbt-docs
```

### Individual Source Extraction
```bash
# Extract from specific sources (using uv run)
uv run meltano run tap-csv-nubank nubank_transactions_mapper target-duckdb
uv run meltano run tap-csv-itau itau_transactions_mapper target-duckdb
uv run meltano run tap-csv-caju caju_transactions_mapper target-duckdb
uv run meltano run tap-csv-alelo alelo_transactions_mapper target-duckdb
uv run meltano run tap-csv-bb bb_transactions_mapper target-duckdb
uv run meltano run tap-csv-c6 c6_transactions_mapper target-duckdb

# Note: Custom taps (tap-btg, tap-nomad) require Python 3.13 compatibility updates
# uv run meltano run tap-btg btg_mapper target-duckdb
# uv run meltano run tap-nomad nomad_transactions_mapper target-duckdb
```

## Development Environment


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
- **Python 3.13** with modern tooling
- **uv** for fast package management
- dbt and SQL extensions configured
- File associations for `.sql` files as `jinja-sql`
- Automatic dependency installation on container creation

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

