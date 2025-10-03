#!/bin/bash
APP_DIR="/home/ubuntu"
INSTANCE_USER=ubuntu

# Redirect stdout/stderr to a log file and the system console
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting user data script execution"

echo "Updating system packages..."
sudo apt update
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
echo "Package update complete."

# Install AWS CLI v2
echo "Installing AWS CLI..."
sudo apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
echo "AWS CLI Installed..."

# Docker Install
echo "Installing Docker..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo newgrp docker
sudo usermod -aG docker $INSTANCE_USER
sudo systemctl enable docker
echo "Docker installation complete."

# Clone repository
echo "Clone Repository..."

cd $APP_DIR
git clone https://github.com/ISIS2503/ISIS2503-Microservices-AppDjango.git
cd $APP_DIR/ISIS2503-Microservices-AppDjango

docker network create kong-net
docker run -d --name kong --network=kong-net --restart=always \
  -v "$(pwd):/kong/declarative/" -e "KONG_DATABASE=off" \
  -e "KONG_DECLARATIVE_CONFIG=/kong/declarative/kong.yaml" \
  -p 8000:8000 kong/kong-gateway

echo "User data script execution finished."