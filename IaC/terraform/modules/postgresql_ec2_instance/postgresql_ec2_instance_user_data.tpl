
##################################################################
# User Data Script for PostgreSQL Installation: 
##################################################################

# Install / Update package lists:
dnf update -y
sudo dnf -y install epel-release
sudo dnf -y install curl
sudo dnf -y install bash-completion
sudo dnf -y install bat
sudo dnf -y install bind-utils
sudo dnf -y install btop
sudo dnf -y install htop
sudo dnf -y install iotop
sudo dnf -y install lsof
sudo dnf -y install telnet
sudo dnf -y install wget
sudo dnf -y install vim
sudo dnf -y install git


# Install Percona PostgreSQL version 17:
sudo dnf module disable postgresql

# Configure Percona PG Repo: 
sudo dnf install https://repo.percona.com/yum/percona-release-latest.noarch.rpm

# Enable the Percona PostgreSQL 17 repository: 
sudo percona-release setup ppg17

# Install Percona PostgreSQL server / pgbackrest and other useful extensions: 
sudo dnf install percona-postgresql17-server
sudo dnf install percona-pgbackrest
sudo dnf install percona-pg_repack17

# Initialize PostgreSQL database
/usr/pgsql-17/bin/postgresql-17-setup initdb

# Enable and start PostgreSQL service
sudo systemctl enable postgresql-17
sudo systemctl start postgresql-17

# Set PostgreSQL to listen on all interfaces
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/17/data/postgresql.conf

# Allow remote connections by modifying pg_hba.conf





##################################################################
# User Data Script for Client PMM Installation: 
##################################################################

ALTER SYSTEM SET pg_stat_monitor.pgsm_enable_query_plan = off;
SELECT pg_reload_conf();


# Install PG_stat_monitor package:
sudo yum install percona-pg-stat-monitor17


vi postgresql.conf
# Add the following lines to postgresql.conf:
`
shared_preload_libraries = 'pg_stat_monitor'
pg_stat_monitor.pgsm_query_max_len = 2048
pg_stat_monitor.pgsm_normalized_query = 1
`

# Restart PostgreSQL service to apply changes: 
systemctl restart postgresql

# Create the pg_stat_monitor extension in the 'postgres' database:
psql -d postgres -c "CREATE EXTENSION pg_stat_monitor;"

# Verify the installation by checking the pg_stat_monitor view:
SELECT pg_stat_monitor_version();



# Install PMM Client: 
sudo yum install pmm-client

# Add Service to PMM: 
pmm-admin add postgresql \
--username=pmm \
--password=password \
--server-url=https://admin:admin@X.X.X.X:443 \
--server-insecure-tls \
--service-name=SERVICE-NAME \
--auto-discovery-limit=10

