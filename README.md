
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

# Testing for Network Policies 

./test_netpol.sh

# Clean Network Policies 

./clean_netpol.sh