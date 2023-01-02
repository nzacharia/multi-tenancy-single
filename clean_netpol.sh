#! /bin/bash
echo -n "" > ./charts/landlord/templates/netpol-default-deny.yaml
 helm upgrade hnc-namespaces  ./charts/landlord/ -f ./charts/landlord/values.sample.yaml