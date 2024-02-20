#!/bin/bash

# Pre-configuracion del repositorio con los archivos
git clone https://github.com/S3B4SZ17/falco_kcd_cr.git
mkdir -p ~/.minikube/files/etc/ssl/certs
cd falco_kcd_cr
cp ./infra/k8s_audit/audit-policy.yaml ~/.minikube/files/etc/ssl/certs/
cp ./infra/k8s_audit/webhook-config.yaml ~/.minikube/files/etc/ssl/certs/

# Creacion del cluster con minikube
minikube start \
  --kubernetes-version=v1.28.2 \
  --extra-config=apiserver.audit-policy-file=/etc/ssl/certs/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=- \
  --extra-config=apiserver.audit-webhook-config-file=/etc/ssl/certs/webhook-config.yaml \
  --extra-config=apiserver.audit-webhook-batch-max-size=10 \
  --extra-config=apiserver.audit-webhook-batch-max-wait=5s \
  --driver=docker
echo "alias k='minikube kubectl --'" >> ~/.bashrc

# Instalacion de helm
cd ~
curl -o helm-v3.10.3-linux-amd64.tar.gz https://get.helm.sh/helm-v3.10.3-linux-amd64.tar.gz
chmod 700 helm-v3.10.3-linux-amd64.tar.gz
tar -zxvf helm-v3.10.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

# Crear un cluster kind
# kind create cluster -n falco-sec --config ./infra/k8s_audit/kind-config.yaml
# kubectl cluster-info --context kind-falco-sec

# Instalar falco
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm install falco \
  --create-namespace \
  --namespace falco \
  --values=infra/falco-values.yaml \
  falcosecurity/falco
