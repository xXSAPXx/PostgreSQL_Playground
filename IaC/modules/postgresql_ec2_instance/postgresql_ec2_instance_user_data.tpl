
###### INSTALL POSTGRESQL #######
# Update package lists
dnf update -y

# Install PostgreSQL veersion 17
dnf install -y postgresql17-server postgresql17-contrib

# Initialize PostgreSQL database
/usr/pgsql-17/bin/postgresql-17-setup initdb

# Enable and start PostgreSQL service
systemctl enable postgresql-17
systemctl start postgresql-17

# Set PostgreSQL to listen on all interfaces
echo "listen_addresses = '*'" >> /var/lib/pgsql/17/data/postgresql.conf

# Allow remote connections by modifying pg_hba.conf
echo "host    all             all

