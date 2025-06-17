FROM frappe/frappe-worker:latest

# Ensure the expected Python path exists for Render's build environment
RUN mkdir -p /opt/render/project/src/env/bin && \
    ln -sf $(which python) /opt/render/project/src/env/bin/python

WORKDIR /home/frappe/frappe-bench

# Copy application code
COPY --chown=frappe:frappe . /home/frappe/frappe-bench/apps/hrms

# Install dependencies
RUN pip install -e /home/frappe/frappe-bench/apps/hrms

# Pre-build frontend assets
WORKDIR /home/frappe/frappe-bench/apps/hrms/frontend
RUN yarn install && yarn build

WORKDIR /home/frappe/frappe-bench
