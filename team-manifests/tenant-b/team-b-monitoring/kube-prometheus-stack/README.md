
# Minikube start without cni
minikube start --network-plugin=cni  --kubernetes-version=v1.24.3 --extra-config=kubeadm.pod-network-cidr=10.244.0.0/16

# Apply calico , hnc , flux , gatekeeper
k create -f setup/1-tigera-operator.yaml
k create  -f setup/2-calico-custom-resources.yaml
k apply -f setup/3-hnc-default.yml
k apply -f setup/4-flux.yaml
k apply -f setup/5-gatekeeper.yaml

# Create CRDs for gatekeeper
helm install ./charts/gk-policy-charts/gk-policy-charts --name-template gk-policy-helm

# Create hnc environment
helm install ./charts/landlord/ -f ./charts/landlord/values.sample.yaml --name-template hnc-namespaces


# Deploy ref-app to namespace app-3 


k apply -n app-3 -f team-manifests/tenant-b/app-3/postgres-config.yml
k apply -n app-3 -f team-manifests/tenant-b/app-3/postgres-pvc-pv.yml
k apply -n app-3 -f team-manifests/tenant-b/app-3/postgres-deployment.yml
k apply -n app-3 -f team-manifests/tenant-b/app-3/postgres-service.yml
k apply -n app-3 -f team-manifests/tenant-b/app-3/deployment.yaml
k apply -n app-3 -f team-manifests/tenant-b/app-3/service.yaml 


# Hnc propagate netpol

kubectl hns config set-resource networkpolicies --mode Propagate
kubectl hns config describe

# Check grafana and prometheus dashboard 

kubectl port-forward service/team-a-monitoring-grafana -n team-a-monitoring 8009:80 
kubectl port-forward service/team-a-monitoring-kube-pro-prometheus -n team-a-monitoring 9090

# Update / Create netpol in netpol-default-deny.yaml

helm upgrade hnc-namespaces  ./charts/landlord/ -f ./charts/landlord/values.sample.yaml