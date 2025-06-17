#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -e

# Create a virtual environment for Frappe Bench
python3 -m venv /opt/render/project/src/.venv_bench
source /opt/render/project/src/.venv_bench/bin/activate

# Create the expected directory and symbolic link for python, pointing to the venv's python
mkdir -p /opt/render/project/src/env/bin
ln -sf /opt/render/project/src/.venv_bench/bin/python /opt/render/project/src/env/bin/python

# Install bench into the virtual environment
/opt/render/project/src/.venv_bench/bin/pip install frappe-bench

# Initialize bench
/opt/render/project/src/.venv_bench/bin/bench init --skip-redis-config-generation --skip-assets-setup --frappe-path https://github.com/frappe/frappe --no-procfile --python /opt/render/project/src/.venv_bench/bin/python frappe-bench
cd frappe-bench

# Get ERPNext and HRMS apps
/opt/render/project/src/.venv_bench/bin/bench get-app erpnext https://github.com/frappe/erpnext
/opt/render/project/src/.venv_bench/bin/bench get-app hrms https://github.com/frappe/hrms

# Start bench
/opt/render/project/src/.venv_bench/bin/bench start
