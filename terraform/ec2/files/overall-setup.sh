#!/bin/bash

# Instalacion de docker y minikube
yum install -y docker git
systemctl start docker
usermod -aG docker ec2-user
chmod 666 /var/run/docker.sock

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

echo "export PATH=$PATH:/usr/local/bin/" >> ~/.bashrc
