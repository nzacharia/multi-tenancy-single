#! /bin/bash

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

testConnection(){

    echo -ne " Connection from [ ${1} ]  Namespace -> [ ${2} ${3} ]     |     Result: "
                                            
    result=$(kubectl run -it --rm --restart=Never netcat-pod --image=alpine  -n ${1} --command -- timeout  3s nc -vz  ${2} ${3} 2> /dev/null)
    if [[ $result == *"punt!"* ]]; then
        echo " FAILED"
    else
        echo  " SUCCEDED"
    fi

}


testConnectionFromPrometheus(){

    echo -ne  " Connection from [ ${2} ]  Prometheus Pod -> [ ${3} ${4} ]     |     Result: "          

    result=$(kubectl exec -it ${1} -n ${2}  --  timeout 3s nc -vz  ${3} ${4}   2> /dev/null   )
    if [[ $result == *"punt!"* ]]; then
        echo  " FAILED"
    else
        echo  " SUCCEDED"
    fi

}

startTesting(){
    ############## App 1 #######################################

    echo "-------------------------------------------------------------"
    testConnection app-1 reference.app-1 80
    testConnection app-1 reference.app-4 80
    testConnection app-1  team-a-monitoring-kube-pro-prometheus.team-a-monitoring 9090
    testConnection app-1  team-b-monitoring-kube-pro-prometheus.team-b-monitoring 9090
    echo "-------------------------------------------------------------"



    # ############## App 4 #######################################
    echo "-------------------------------------------------------------"
    testConnection app-4 reference.app-1 80
    testConnection app-4 reference.app-4 80
    testConnection app-4  team-a-monitoring-kube-pro-prometheus.team-a-monitoring 9090
    testConnection app-4  team-b-monitoring-kube-pro-prometheus.team-b-monitoring 9090
    echo "-------------------------------------------------------------"
    # ############## Prometheus Team-A-Monitoring #######################################
    echo "-------------------------------------------------------------"
    testConnectionFromPrometheus prometheus-team-a-monitoring-kube-pro-prometheus-0 team-a-monitoring reference.app-1 80
    testConnectionFromPrometheus prometheus-team-a-monitoring-kube-pro-prometheus-0 team-a-monitoring reference.app-4 80
    testConnectionFromPrometheus prometheus-team-a-monitoring-kube-pro-prometheus-0 team-a-monitoring team-a-monitoring-grafana.team-a-monitoring 80
    testConnectionFromPrometheus prometheus-team-a-monitoring-kube-pro-prometheus-0 team-a-monitoring team-b-monitoring-kube-pro-prometheus.team-b-monitoring 9090
    echo "-------------------------------------------------------------"
    # ############## Prometheus Team-B-Monitoring #######################################
    echo "-------------------------------------------------------------"
    testConnectionFromPrometheus prometheus-team-b-monitoring-kube-pro-prometheus-0 team-b-monitoring reference.app-1 80
    testConnectionFromPrometheus prometheus-team-b-monitoring-kube-pro-prometheus-0 team-b-monitoring reference.app-4 80
    testConnectionFromPrometheus prometheus-team-b-monitoring-kube-pro-prometheus-0 team-b-monitoring team-b-monitoring-grafana.team-b-monitoring 80
    testConnectionFromPrometheus prometheus-team-b-monitoring-kube-pro-prometheus-0 team-b-monitoring team-a-monitoring-kube-pro-prometheus.team-a-monitoring 9090
    echo "-------------------------------------------------------------"
}


kubectl hns config set-resource networkpolicies --mode Propagate

kubectl hns config describe


kubectl get netpol -A 

echo "################################################"
echo "                                               #"
echo "Testing connections without Network Policies   #"
echo "                                               #"
echo "################################################"

startTesting



cat << EOF >> ./charts/landlord/templates/netpol-default-deny.yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: cecg
  name: deny-from-other-namespaces
spec:
  podSelector:
    matchLabels:
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector: {}
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: cecg
  name: allow-egress-kube-dns
spec:
  podSelector:
    matchLabels:
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
      - port: 53
        protocol: UDP
      - port: 53
        protocol: TCP
  - to:
     - podSelector:
        matchLabels: 
---
EOF

 helm upgrade hnc-namespaces  ./charts/landlord/ -f ./charts/landlord/values.sample.yaml

sleep 10 

kubectl get netpol -A 

echo "###############################################################################################"
echo "                                                                                              #"
echo "Testing connections : Network Policies -  deny-from-other-namespaces |  allow-egress-kube-dns #"
echo "                                                                                              #"
echo "###############################################################################################"

startTesting


cat << EOF >> ./charts/landlord/templates/netpol-default-deny.yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: tenant-a
  name: tenant-a-allow-ingress-team-a-monitoring
spec:
  podSelector:
    matchLabels:
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: team-a-monitoring
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: tenant-a
  name: tenant-a-allow-egress-to-team-a-monitoring
spec:
  podSelector:
    matchLabels:
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: team-a-monitoring
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: team-a-monitoring
  name: team-a-monitoring-allow-ingress-from-tenant-a
spec:
  podSelector:
    matchLabels:
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tenant/name: tenant-a
---
EOF


 helm upgrade hnc-namespaces  ./charts/landlord/ -f ./charts/landlord/values.sample.yaml

echo "###############################################################################################"
echo "                                                                                              #"
echo "Testing connections : Network Policies -  allow-ingress-egress-tenant-a-to-team-a-monitoring  #"
echo "                                                                                              #"
echo "###############################################################################################"

startTesting


cat << EOF >> ./charts/landlord/templates/netpol-default-deny.yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: tenant-b
  name: tenant-b-allow-ingress-team-b-monitoring
spec:
  podSelector:
    matchLabels:
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: team-b-monitoring
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: tenant-b
  name: tenant-b-allow-egress-to-team-b-monitoring
spec:
  podSelector:
    matchLabels:
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: team-b-monitoring
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: team-b-monitoring
  name: team-b-monitoring-allow-ingress-from-tenant-b
spec:
  podSelector:
    matchLabels:
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tenant/name: tenant-b
---
EOF



 helm upgrade hnc-namespaces  ./charts/landlord/ -f ./charts/landlord/values.sample.yaml

echo "###############################################################################################"
echo "                                                                                              #"
echo "Testing connections : Network Policies -  allow-ingress-egress-tenant-b-to-team-a-monitoring  #"
echo "                                                                                              #"
echo "###############################################################################################"

startTesting