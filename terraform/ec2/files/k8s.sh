#!/bin/bash

# Wait until the instance is ready
echo 'Waiting for user data script to finish'
sudo cloud-init status --wait
sleep 10

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

cat <<EOF > ~/nginx.conf
events {}

http {
  server {
    listen       80;

    location /webhook {
      proxy_pass http://`minikube ip`:30009;
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto \$scheme;

      # Content-Type
      proxy_set_header Content-Type \$http_content_type;
      
      # Add any other headers you need to pass
      # GitHub headers
      proxy_set_header X-GitHub-Delivery \$http_x_github_delivery;
      proxy_set_header X-GitHub-Event \$http_x_github_event;
      proxy_set_header X-GitHub-Hook-ID \$http_x_github_hook_id;
      proxy_set_header X-GitHub-Hook-Installation-Target-ID \$http_x_github_hook_installation_target_id;
      proxy_set_header X-GitHub-Hook-Installation-Target-Type \$http_x_github_hook_installation_target_type;
      proxy_set_header X-Hub-Signature \$http_x_hub_signature;
      proxy_set_header X-Hub-Signature-256 \$http_x_hub_signature_256;
    }

    location / {
      proxy_pass http://`minikube ip`:30282;
      
      # Add any other headers you need to pass
      # proxy_set_header Header-Name Header-Value;
    }
  }
}
error_log  /var/log/nginx_error.log;
EOF

# Crear un cluster kind
# kind create cluster -n falco-sec --config ./infra/k8s_audit/kind-config.yaml
# kubectl cluster-info --context kind-falco-sec

# Instalar falco
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm install falco \
  --create-namespace \
  --namespace falco \
  --values=/home/ec2-user/values.yaml \
  --values=falco_kcd_cr/infra/falco-values.yaml \
  falcosecurity/falco

# Se espera a que falco este listo
sleep 60

# Se configura un nginx reverse proxy

docker run -d \
  --name nginx \
  -p 80:80 \
  -v /home/ec2-user/nginx.conf:/etc/nginx/nginx.conf \
  --network minikube \
  nginx

# Example commands
# k run -i --tty --rm debug --image=nicolaka/netshoot --restart=Never -- sh
# find / -name ~/.aws/credentials
# k create cm  myconfigmap --from-literal=username=admin --from-literal=password=123456

# Install sysdig cli
# apt update -y; apt install sysdig -y
