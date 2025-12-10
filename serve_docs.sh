#!/bin/bash

# Navigate to the project directory (where this script is located)
cd "$(dirname "$0")"

# Activate the virtual environment
# Assuming the .venv is in the parent directory as seen in previous steps
source ../.venv/bin/activate

# Generate the documentation to ensure it's up-to-date
echo "Generating dbt documentation..."
dbt docs generate

# Serve the documentation
echo "Serving dbt documentation..."
dbt docs serve
