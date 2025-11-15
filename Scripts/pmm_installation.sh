#!/bin/bash

# Exit on error, undefined variable, or error in a pipeline
set -eo pipefail 

# Variables:
PG_CONF="/var/lib/pgsql/17/data/postgresql.conf"
PG_HBA="/var/lib/pgsql/17/data/pg_hba.conf"
PMM_PUBLIC_IP=$1

# Check if PMM Server Public IP was passed
if [ -z "$1" ]; then
    echo "❌ ERROR: PMM server public IP not provided."
    echo "Usage: $0 <PMM_PUBLIC_IP>"
    exit 1
fi

echo "➡ Registering PMM Client with PMM Server at $PMM_PUBLIC_IP..."

###############################################################################
# Script for | percona-pg-stat-monitor | Installation: 
###############################################################################

sudo -u postgres psql -c "ALTER SYSTEM SET pg_stat_monitor.pgsm_enable_query_plan = off;"
sudo -u postgres psql -c "SELECT pg_reload_conf();"

# Install PG_stat_monitor package:
sudo dnf -y install percona-pg-stat-monitor17

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Update PostgreSQL configuration file to load the pg_stat_monitor extension:

# 1. Update the shared_preload_libraries line (Eeplaces entire line if it already exists)
sudo sed -i "s|^#*shared_preload_libraries *=.*|shared_preload_libraries = 'pg_stat_monitor'|" "$PG_CONF"

# 2. Ensure the pg_stat_monitor parameters are added right below shared_preload_libraries (Only add if not already present)
sudo grep -q "pg_stat_monitor.pgsm_query_max_len" "$PG_CONF" || \
  sudo sed -i "/shared_preload_libraries/a pg_stat_monitor.pgsm_query_max_len = 2048" "$PG_CONF"

sudo grep -q "pg_stat_monitor.pgsm_normalized_query" "$PG_CONF" || \
  sudo sed -i "/shared_preload_libraries/a pg_stat_monitor.pgsm_normalized_query = 1" "$PG_CONF"

sudo grep -q "pg_stat_monitor.pgsm_enable_query_plan" "$PG_CONF" || \
  sudo sed -i "/shared_preload_libraries/a pg_stat_monitor.pgsm_enable_query_plan = on" "$PG_CONF"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Restart PostgreSQL service to apply changes: 
sudo systemctl restart postgresql-17
sleep 5

# Create the pg_stat_monitor extension in the 'postgres' database:
sudo -u postgres psql -d postgres -c "CREATE EXTENSION pg_stat_monitor;"

# Verify the installation by checking the pg_stat_monitor view:
sudo -u postgres psql -d postgres -c "SELECT pg_stat_monitor_version();"



##################################################################
# Script for Client PMM Installation: 
##################################################################

# Enable Percona PMM Repository:
sudo percona-release disable all
sudo percona-release enable pmm3-client

# Install PMM Client: 
sudo dnf -y install pmm-client


# Create PMM User in PostgreSQL:
sudo -u postgres psql -c "CREATE USER pmm WITH SUPERUSER ENCRYPTED PASSWORD 'stronG_Password1234#';"
sudo sed -i '/^# "local" is for Unix domain socket connections only/a local   all             pmm                                  scram-sha-256' "$PG_HBA"
sudo -u postgres psql -c "SELECT pg_reload_conf();"


##################################################################
# PMM Client Registration:
##################################################################

# Register PMM Client to PMM Server
pmm-admin config --server-insecure-tls \
  --server-url="https://admin:admin@${PMM_PUBLIC_IP}:443"

# Add PostgreSQL service to PMM
pmm-admin add postgresql \
  --username=pmm \
  --password="stronG_Password1234#" \
  --server-url="https://admin:admin@${PMM_PUBLIC_IP}:443" \
  --server-insecure-tls \
  --service-name="postgresql-source" \
  --auto-discovery-limit=10

echo "✅ PMM registration completed."

