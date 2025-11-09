#!/bin/bash


##################################################################
# Hostname and /etc/hosts configuration: 
##################################################################

# Switch to root user: 
sudo su - root

# Set hostname: 
HOSTNAME="postgresql-source"
sudo hostnamectl set-hostname "$HOSTNAME"

# Update /etc/hosts file: 
sudo bash -c "cat <<EOF > /etc/hosts
127.0.0.1   localhost $HOSTNAME
EOF"


##################################################################
# User Data Script for Percona PostgreSQL Installation: 
##################################################################

# Variables:
PG_CONF="/var/lib/pgsql/17/data/postgresql.conf"
PG_HBA="/var/lib/pgsql/17/data/pg_hba.conf"

# Install / Update package lists:
#sudo dnf update -y
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf -y install curl
sudo dnf -y install bash-completion
sudo dnf -y install bat
sudo dnf -y install bind-utils
sudo dnf -y install btop
sudo dnf -y install iotop
sudo dnf -y install telnet
sudo dnf -y install vim


# Install Percona PostgreSQL version 17:
sudo dnf -y module disable postgresql

# Configure Percona PG Repo: 
sudo dnf -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm

# Enable the Percona PostgreSQL 17 repository: 
sudo percona-release setup ppg17

# Install Percona PostgreSQL server / pgbackrest and other useful extensions: 
sudo dnf -y install percona-postgresql17-server
sudo dnf -y install percona-pgbackrest
sudo dnf -y install percona-pg_repack17

# Initialize PostgreSQL database
/usr/pgsql-17/bin/postgresql-17-setup initdb

# Enable and start PostgreSQL service
sudo systemctl enable postgresql-17
sudo systemctl start postgresql-17

# Set PostgreSQL to listen on all interfaces
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" $PG_CONF

# Allow remote connections by modifying pg_hba.conf: 

# Give postgres user sudo privileges: 
echo "postgres ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/postgres

 

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
# User Data Script for Client PMM Installation: 
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

