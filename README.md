# Concept and Roles

## Platform engineer 

Responsible for cluster configuration and isolation of org / tenants.
Also is administartor of repo https://github.com/nzacharia/multi-tenancy-single and is managing the cluster through 
https://github.com/nzacharia/multi-tenancy-single/blob/main/charts/landlord/values.sample.yaml

<img width="527" alt="image" src="https://user-images.githubusercontent.com/118350416/210253136-44d558b1-7c31-4aee-b06e-3c1f726c8bbf.png">

To add a new org with name <testorg> : 
```
org:
 - cecg:
    .
    .
 - testorg:
    flux:
      path: ./team-manifests/cecg. # This the "virtual" repo (for the bootcamp , instead of creating new repo for each org/tenant we 're creating a subfolder for each org/tenant
```



To add a new tenant with name <tenanttest> : 
```
org:
 - cecg:
    .
    .
 - testorg:
    tenants:
     - tenanttest:
        flux:
           path: ./team-manifests/tenanttest
```
To add a new subnamespace with name <subnstest> : 
```
org:
 - cecg:
    .
    .
 - testorg:
    tenants:
     - tenanttest:
        flux:
           path: ./team-manifests/tenanttest
        subnamespaces:
          - name: subnstest
            flux:
              path: ./team-manifests/tenanttest/subnstest
            podLimits:  # This is a Gatekeeper policy . Platform engineer can define the resources/limits of pods in each namespace
               memory: 256Mi
               cpu:  500m
```

To remove a subnamespace / tenant / org , platform engineer has to delete the values from https://github.com/nzacharia/multi-tenancy-single/blob/main/charts/landlord/values.sample.yaml




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


<img width="1073" alt="image" src="https://user-images.githubusercontent.com/118350416/210254801-c8cf944c-c009-4785-bc93-2b9308ff4dca.png">
<img width="1093" alt="image" src="https://user-images.githubusercontent.com/118350416/210254831-b70c8a33-f1f2-481a-8ab4-b9324eee700a.png">
<img width="1044" alt="image" src="https://user-images.githubusercontent.com/118350416/210254858-d2e042a1-50c1-4245-969e-77104dca3bfd.png">
<img width="1064" alt="image" src="https://user-images.githubusercontent.com/118350416/210254930-db6b3bb3-0e79-43bf-9763-c1960cec8784.png">

# Clean Network Policies 

./clean_netpol.sh
