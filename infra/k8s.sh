# Create a K8s cluster with kind
brew install kind

# Create a cluster with minikube
mkdir -p ~/.minikube/files/etc/ssl/certs
cp ./infra/k8s_audit/audit-policy.yaml ~/.minikube/files/etc/ssl/certs/
cp ./infra/k8s_audit/webhook-config.yaml ~/.minikube/files/etc/ssl/certs/
minikube start \
  --extra-config=apiserver.audit-policy-file=/etc/ssl/certs/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=- \
  --extra-config=apiserver.audit-webhook-config-file=/etc/ssl/certs/webhook-config.yaml \
  --extra-config=apiserver.audit-webhook-batch-max-size=10 \
  --extra-config=apiserver.audit-webhook-batch-max-wait=5s

# Create a cluster with kind
# kind create cluster -n falco-sec --config ./infra/k8s_audit/kind-config.yaml
# kubectl cluster-info --context kind-falco-sec

# Install falco
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm install falco \
  --create-namespace \
  --namespace falco \
  --values=infra/falco-values.yaml \
  falcosecurity/falco
