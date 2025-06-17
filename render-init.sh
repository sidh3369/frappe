#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -e

# Create a virtual environment for Frappe Bench
python3 -m venv /opt/render/project/src/.venv_bench
source /opt/render/project/src/.venv_bench/bin/activate

# Create the expected directory and symbolic link for python, pointing to the venv's python
mkdir -p /opt/render/project/src/env/bin
ln -sf $(which python) /opt/render/project/src/env/bin/python

# Install bench into the virtual environment
pip install frappe-bench

# Initialize bench
/opt/render/project/src/.venv_bench/bin/bench init --skip-redis-config-generation --skip-assets-setup --frappe-path https://github.com/frappe/frappe --no-procfile --python /opt/render/project/src/.venv_bench/bin/python frappe-bench
cd frappe-bench

# Configure database
/opt/render/project/src/.venv_bench/bin/bench set-mariadb-host $DB_HOST
/opt/render/project/src/.venv_bench/bin/bench set-redis-cache-host $REDIS_CACHE_QUEUE_HOST
/opt/render/project/src/.venv_bench/bin/bench set-redis-queue-host $REDIS_CACHE_QUEUE_HOST
/opt/render/project/src/.venv_bench/bin/bench set-redis-socketio-host $REDIS_SOCKETIO_HOST

# Get ERPNext and HRMS apps
/opt/render/project/src/.venv_bench/bin/bench get-app erpnext https://github.com/frappe/erpnext
/opt/render/project/src/.venv_bench/bin/bench get-app hrms https://github.com/frappe/hrms

# Create new site
/opt/render/project/src/.venv_bench/bin/bench new-site $SITE_NAME --mariadb-root-username $DB_USERNAME --mariadb-root-password $DB_PASSWORD --admin-password $ADMIN_PASSWORD

# Install apps
/opt/render/project/src/.venv_bench/bin/bench --site $SITE_NAME install-app erpnext
/opt/render/project/src/.venv_bench/bin/bench --site $SITE_NAME install-app hrms

# Set developer mode
/opt/render/project/src/.venv_bench/bin/bench --site $SITE_NAME set-config developer_mode 1

# Enable scheduler
/opt/render/project/src/.venv_bench/bin/bench --site $SITE_NAME enable-scheduler

# Clear cache
/opt/render/project/src/.venv_bench/bin/bench --site $SITE_NAME clear-cache

# Start bench
/opt/render/project/src/.venv_bench/bin/bench start
