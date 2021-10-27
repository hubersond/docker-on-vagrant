#!/usr/bin/env bash

# check if docker-ce already installed and abort
command -v docker >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo $(docker -v) " is currently installed."
    exit
fi

# remove old docker version(docker.io)
sudo apt-get remove docker docker-engine docker.io containerd runc

# update system and install dependencies 
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

# Add repository and install docker
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
#
sudo apt-get update && sudo apt-get -y install docker-ce docker-ce-cli containerd.io
# Test that it's up
sudo docker run hello-world
# Enable startup on boot
sudo systemctl enable docker

# Add docker group to eliminate root-only access to docker commands
sudo groupadd docker
sudo usermod -aG docker vagrant

docker run hello-world

# Enable remote access
host_ip=$ENV_IP
#
## Fixes issue that prevent dockerd to start after setting tcp 
##   listening in 'daemon.json'.
## https://docs.docker.com/config/daemon/#troubleshoot-conflicts-between-the-daemonjson-and-startup-scripts
sudo mkdir /etc/systemd/system/docker.service.d
cat >> /etc/systemd/system/docker.service.d/docker.conf << EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
EOF
#
# sudo mkdir /etc/systemd/system/docker.service.d
# sudo mv docker.conf /etc/systemd/system/docker.service.d/docker.conf
#
## Set Docker daemon(dockerd) listening address
cat >> /etc/docker/daemon.json << EOF
{
    "hosts": ["unix:///var/run/docker.sock", "tcp://$host_ip:2375"]
}
EOF
sudo systemctl daemon-reload && sudo systemctl restart docker.service

# Enable swarm mode
docker swarm init --advertise-addr $host_ip

if [[ $? -eq 0 ]]; then
    echo "Docker Up & Rolling"
fi

