
##################################################################
# User Data Script for PostgreSQL EC2 Instance: 
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

