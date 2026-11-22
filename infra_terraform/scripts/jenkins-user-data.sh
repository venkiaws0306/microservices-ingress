#!/bin/bash
set -euxo pipefail
apt-get update -y
apt-get install -y fontconfig openjdk-17-jre-headless curl wget gnupg ca-certificates
install -m 0755 -d /etc/apt/keyrings
wget -qO- https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | gpg --dearmor -o /etc/apt/keyrings/jenkins.gpg
chmod 644 /etc/apt/keyrings/jenkins.gpg
echo "deb [signed-by=/etc/apt/keyrings/jenkins.gpg] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update -y
apt-get install -y jenkins
systemctl enable --now jenkins

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker jenkins
systemctl enable --now docker
systemctl restart jenkins
