FROM frappe/frappe-worker:latest

WORKDIR /home/frappe/frappe-bench

# Copy application code
COPY --chown=frappe:frappe . /home/frappe/frappe-bench /apps/hrms

# Pre-build frontend assets
WORKDIR /home/frappe/frappe-bench/apps/hrms/frontend
RUN yarn install && yarn build

WORKDIR /home/frappe/frappe-bench

# Set the command to run the application
CMD ["bench", "start"]
