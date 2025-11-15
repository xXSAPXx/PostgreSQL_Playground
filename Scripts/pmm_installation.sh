
###############################################################################
# User Data Script for | percona-pg-stat-monitor | Installation: 
###############################################################################

sudo su - postgres
psql -c "ALTER SYSTEM SET pg_stat_monitor.pgsm_enable_query_plan = off;"
psql -c "SELECT pg_reload_conf();"

# Install PG_stat_monitor package:
sudo su - root
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
sudo su - postgres
psql -d postgres -c "CREATE EXTENSION pg_stat_monitor;"

# Verify the installation by checking the pg_stat_monitor view:
psql -d postgres -c "SELECT pg_stat_monitor_version();"



##################################################################
# Script for Client PMM Installation: 
##################################################################

# Enable Percona PMM Repository:
sudo su - root
percona-release disable all
percona-release enable pmm3-client

# Install PMM Client: 
sudo dnf -y install pmm-client


# Create PMM User in PostgreSQL:
sudo su - postgres
psql -c "CREATE USER pmm WITH SUPERUSER ENCRYPTED PASSWORD 'stronG_Password1234#';"
sudo sed -i '/^# "local" is for Unix domain socket connections only/a local   all             pmm                                  scram-sha-256' "$PG_HBA"
psql -c "SELECT pg_reload_conf();"



# Register PMM Client to PMM Server:
pmm-admin config --server-insecure-tls \
--server-url=https://admin:admin@34.229.86.1:443


# Add Service to PMM: 
pmm-admin add postgresql \
--username=pmm \
--password=stronG_Password1234# \
--server-url=https://admin:admin@34.229.86.1:443 \
--server-insecure-tls \
--service-name=postgresql-source \
--auto-discovery-limit=10

