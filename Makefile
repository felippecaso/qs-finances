# Environment setup
build:
	uv sync
	uv run meltano install

# Development workflow
dev-install:
	uv sync --extra dev
	uv run meltano install

format:
	uv run black .
	uv run ruff check --fix .

lint:
	uv run ruff check .
	uv run mypy .

test:
	uv run pytest

test-cov:
	uv run pytest --cov=src --cov-report=html

# Meltano operations (using uv run)
load-to-duckdb:
	uv run meltano run load-finances-to-duckdb

load-to-csv:
	uv run meltano run load-finances-to-csv

dbt-run:
	uv run meltano invoke dbt-duckdb:run

dbt-test:
	uv run meltano invoke dbt-duckdb:test

dbt-docs:
	uv run meltano invoke dbt-duckdb:docs generate


# Data visualization
rill-install:
	curl -s https://cdn.rilldata.com/install.sh | bash

rill-build:
	mkdir -p rill
	cd rill && rill init
	cd rill && for file in ../data/catalog/*.parquet; do rill source add $$file; done

rill-run:
	cd rill && rill start

rill-visuals:
	make rill-install
	make rill-build
	make rill-run