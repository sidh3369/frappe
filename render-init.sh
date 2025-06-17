#!/bin/bash

# Create a symlink to the correct Python location
mkdir -p /opt/render/project/src/env/bin
ln -sf $(which python) /opt/render/project/src/env/bin/python

# Initialize Frappe bench
bench init --frappe-path=https://github.com/frappe/frappe --frappe-branch=version-14 frappe-bench
cd frappe-bench

# Configure database and Redis
bench set-config -g db_host $DB_HOST
bench set-config -g db_port $DB_PORT
bench set-config -g db_name $DB_NAME
bench set-config -g db_password $DB_PASSWORD

bench set-config -g redis_cache "redis://${REDIS_CACHE}:6379"
bench set-config -g redis_queue "redis://${REDIS_QUEUE}:6379"
bench set-config -g redis_socketio "redis://${REDIS_SOCKETIO}:6379"

# Remove redis and watch from Procfile
sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

# Get ERPNext and HRMS apps
bench get-app --branch version-14 erpnext https://github.com/frappe/erpnext
bench get-app hrms https://github.com/frappe/hrms

# Create a new site
bench new-site site1.local --mariadb-root-password $MYSQL_ROOT_PASSWORD --admin-password $ADMIN_PASSWORD
bench --site site1.local install-app erpnext
bench --site site1.local install-app hrms

# Set developer mode and enable scheduler
bench --site site1.local set-config developer_mode 1
bench --site site1.local enable-scheduler

# Clear cache and start bench
bench --site site1.local clear-cache
bench start
