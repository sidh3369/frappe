#!/bin/bash

# Initialize bench if not already done
if [ ! -d "frappe-bench" ]; then
  bench init --skip-redis-config-generation frappe-bench
  cd frappe-bench
  
  # Configure Redis from environment variable
  bench set-redis-cache-host $REDIS_URL
  bench set-redis-queue-host $REDIS_URL
  bench set-redis-socketio-host $REDIS_URL
  
  # Remove redis, watch from Procfile
  sed -i '/redis/d' ./Procfile
  sed -i '/watch/d' ./Procfile
  
  # Get apps
  bench get-app erpnext
  bench get-app hrms
  
  # Create site with external database
  bench new-site $FRAPPE_SITE \
  --db-host $DB_HOST \
  --db-name $DB_NAME \
  --db-user $DB_USER \
  --db-password $DB_PASSWORD \
  --admin-password $ADMIN_PASSWORD
  
  bench --site $FRAPPE_SITE install-app hrms
  bench --site $FRAPPE_SITE set-config developer_mode $FRAPPE_DEVELOPER_MODE
  bench --site $FRAPPE_SITE enable-scheduler
  bench use $FRAPPE_SITE
fi

# Start the application
exec bench start
