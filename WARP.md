# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a **Quantified Self project for personal finances data using the Modern Data Stack**. The project extracts financial transaction data from multiple sources (banks, credit cards, investment platforms) and processes it through a Meltano-based ELT pipeline with dbt transformations, storing the results in DuckDB and exporting to CSV/Parquet formats.

## Key Development Commands

### Initial Setup
```bash
# Install all Meltano plugins and dependencies
make build

# Alternative: Install Meltano plugins directly
meltano install
```

### Data Pipeline Operations
```bash
# Load data from all financial sources to DuckDB
meltano run load-finances-to-duckdb

# Load data from all financial sources to CSV/Parquet files
meltano run load-finances-to-csv

# Run dbt transformations
meltano invoke dbt-duckdb:run

# Test dbt models
meltano invoke dbt-duckdb:test

# Generate dbt documentation
meltano invoke dbt-duckdb:docs generate
```

### Individual Data Source Extraction
```bash
# Extract from specific sources (examples)
meltano run tap-csv-nubank nubank_transactions_mapper target-duckdb
meltano run tap-btg btg_mapper target-duckdb
meltano run tap-csv-itau itau_transactions_mapper target-duckdb
```

### Development Environment
```bash
# Start Jupyter Lab for data exploration
meltano invoke jupyterlab:launch
```

### Visualization with Rill
```bash
# Install, build and run Rill for data visualization
make rill-visuals

# Individual commands
make rill-install  # Install Rill
make rill-build    # Build Rill project with data sources
make rill-run      # Start Rill server
```

## Architecture Overview

### Data Flow Architecture
The project follows an ELT (Extract, Load, Transform) pattern:
1. **Extract**: Multiple tap extractors pull data from various financial institutions
2. **Load**: Data is loaded into DuckDB and/or CSV files via Meltano targets
3. **Transform**: dbt handles data modeling and transformations
4. **Visualize**: Rill provides interactive dashboards

### Core Components

#### Meltano Configuration (`meltano.yml`)
- **Extractors**: Custom taps for BTG, Nomad, and CSV-based sources (Nubank, Itaú, C6, BB, Alelo, Caju)
- **Loaders**: DuckDB and CSV targets for different storage needs
- **Mappers**: Stream transformations for data standardization (date parsing, field mapping, filtering)
- **Utilities**: JupyterLab for analysis

#### Data Sources Integration
- **S3-based sources**: Raw files stored in `s3://felippe-data/raw/` for different institutions
- **Custom taps**: `tap-btg` and `tap-nomad` for proprietary data formats
- **CSV processors**: Standardized handling for bank export files with institution-specific configurations

#### dbt Transformation Layer
- **Project structure**: `transform/` directory with standard dbt layout
- **Materialization strategy**: 
  - Staging/Intermediate models: ephemeral (in-memory)
  - Marts: table materialization with automatic CSV/Parquet export
- **Custom macros**: Auto-export functionality for models to multiple formats

#### Data Storage
- **Primary database**: DuckDB (`data/catalog/qsmds.duckdb`)
- **Export formats**: CSV and Parquet files in `data/catalog/`
- **Raw data**: S3 bucket with institution-specific folders

### Development Container
The project includes DevContainer configuration for VS Code:
- Python 3.9 with Meltano pre-installed
- SQL/dbt extensions configured
- File associations for `.sql` files as `jinja-sql`

### Scheduled Operations
- Weekly data loading job configured: `weekly-finances-load`
- Runs `load-finances-to-csv` job automatically

## Important Files and Directories

- `meltano.yml`: Complete pipeline configuration including all sources, transformations, and jobs
- `transform/dbt_project.yml`: dbt configuration with materialization rules and export hooks
- `transform/macros/`: Custom dbt macros for CSV/Parquet export functionality
- `notebook/`: Jupyter notebooks for data exploration
- `data/catalog/`: Output directory for processed data files and DuckDB database
- `.devcontainer/`: VS Code development container configuration