# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a **Quantified Self project for personal finances data using the Modern Data Stack**. The project extracts financial transaction data from multiple sources (banks, credit cards, investment platforms) and processes it through a Meltano-based ELT pipeline with dbt transformations, storing the results in DuckDB and exporting to CSV/Parquet formats.

## Environment Management

This project supports two environments:
- **dev**: Uses local DuckDB file (`./data/catalog/qsmds.duckdb`) for development
- **prod**: Uses MotherDuck cloud database (`md:qsmds`) for production

### Environment Selection
```bash
# Check current environment (defaults to 'dev')
uv run meltano config meltano environment

# Switch to development environment (default)
export MELTANO_ENVIRONMENT=dev
# OR: uv run meltano --environment=dev <command>

# Switch to production environment
export MELTANO_ENVIRONMENT=prod
# OR: uv run meltano --environment=prod <command>
```

## Key Development Commands

### Initial Setup
```bash
# Install Python dependencies with uv and Meltano plugins
make build

# Alternative: Manual installation
uv sync                    # Install Python dependencies
uv run meltano install     # Install Meltano plugins

# Development setup with additional tools
make dev-install           # Install with linting, testing, formatting tools
```

### Data Pipeline Operations

#### Development Environment (Local DuckDB)
```bash
# Load data from all financial sources to local DuckDB
uv run meltano run load-finances-to-duckdb
# OR: make load-to-duckdb

# Load data from all financial sources to CSV/Parquet files
uv run meltano run load-finances-to-csv
# OR: make load-to-csv

# Run dbt transformations on local DuckDB
uv run meltano invoke dbt-duckdb:run
# OR: make dbt-run

# Test dbt models
uv run meltano invoke dbt-duckdb:test
# OR: make dbt-test

# Generate dbt documentation
uv run meltano invoke dbt-duckdb:docs generate
# OR: make dbt-docs
```

#### Production Environment (MotherDuck Cloud)
```bash
# Load data to MotherDuck (requires MOTHERDUCK_TOKEN env var)
export MELTANO_ENVIRONMENT=prod
uv run meltano run load-finances-to-duckdb

# Run dbt transformations on MotherDuck
uv run meltano --environment=prod invoke dbt-duckdb:run

# Test dbt models on MotherDuck
uv run meltano --environment=prod invoke dbt-duckdb:test
```

### Individual Data Source Extraction

#### Development Environment (Local DuckDB)
```bash
# Extract from specific sources to local DuckDB (default dev environment)
uv run meltano run tap-csv-nubank nubank_transactions_mapper target-duckdb
uv run meltano run tap-csv-itau itau_transactions_mapper target-duckdb
uv run meltano run tap-csv-c6 c6_transactions_mapper target-duckdb
uv run meltano run tap-csv-bb bb_transactions_mapper target-duckdb
uv run meltano run tap-csv-alelo alelo_transactions_mapper target-duckdb
uv run meltano run tap-csv-caju caju_transactions_mapper target-duckdb

# Note: Custom taps require Python 3.13 compatibility updates
# uv run meltano run tap-btg btg_mapper target-duckdb
# uv run meltano run tap-nomad nomad_transactions_mapper target-duckdb
```

#### Production Environment (MotherDuck Cloud)
```bash
# Extract from specific sources to MotherDuck
uv run meltano --environment=prod run tap-csv-nubank nubank_transactions_mapper target-duckdb
uv run meltano --environment=prod run tap-csv-itau itau_transactions_mapper target-duckdb
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

## Modern Development Workflow

This project uses **Python 3.13+** and **uv** for fast, reliable package management.

### Code Quality Tools
```bash
# Development setup with linting and testing
make dev-install

# Format code automatically
make format             # Black + Ruff autofix

# Check code quality
make lint               # Ruff + MyPy

# Run tests
make test               # Pytest
make test-cov           # Pytest with coverage
```

### Key Technologies
- **uv**: Ultra-fast Python package installer and resolver
- **Python 3.13**: Latest Python with performance improvements
- **pyproject.toml**: Modern Python project configuration
- **Black + Ruff**: Code formatting and linting
- **pytest**: Testing framework

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
- **Development database**: Local DuckDB (`./data/catalog/qsmds.duckdb`)
- **Production database**: MotherDuck cloud database (`md:qsmds`)
- **Export formats**: CSV and Parquet files in `data/catalog/` (dev only)
- **Raw data**: S3 bucket with institution-specific folders (`s3://felippe-data/raw/`)

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