# Install Docker and run PMM: 
sudo curl -fsSL https://www.percona.com/get/pmm | /bin/bash

# Enable Docker Service:
sudo systemctl enable docker
sudo systemctl start docker

