#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -e

# Create the expected directory and symbolic link for python
mkdir -p /opt/render/project/src/env/bin
ln -sf $(which python) /opt/render/project/src/env/bin/python

# Install bench
pip install frappe-bench

# Initialize bench
bench init --skip-redis-config-generation --skip-assets-setup --frappe-path https://github.com/frappe/frappe --no-procfile --python $(which python) frappe-bench
cd frappe-bench

# Configure database
bench set-mariadb-host $DB_HOST
bench set-redis-cache-host $REDIS_CACHE_QUEUE_HOST
bench set-redis-queue-host $REDIS_CACHE_QUEUE_HOST
bench set-redis-socketio-host $REDIS_SOCKETIO_HOST

# Get ERPNext and HRMS apps
bench get-app erpnext https://github.com/frappe/erpnext
bench get-app hrms https://github.com/frappe/hrms

# Create new site
bench new-site $SITE_NAME --mariadb-root-username $DB_USERNAME --mariadb-root-password $DB_PASSWORD --admin-password $ADMIN_PASSWORD

# Install apps
bench --site $SITE_NAME install-app erpnext
bench --site $SITE_NAME install-app hrms

# Set developer mode
bench --site $SITE_NAME set-config developer_mode 1

# Enable scheduler
bench --site $SITE_NAME enable-scheduler

# Clear cache
bench --site $SITE_NAME clear-cache

# Start bench
bench start
