#!/bin/bash

# exit when any command fails
set -e

if [ $# == 0 ]; then
  CLUSTER="tst"
else
  CLUSTER="$1"
fi


# switch to correct cluster
kubectx farmdoc-${CLUSTER}

# make sure farmdoc namespace exists
kubectl create namespace farmdoc || true

# load secret to pull images
kubectl -n farmdoc create secret generic regcred --from-file=.dockerconfigjson=regcred.json --type=kubernetes.io/dockerconfigjson || true

# create PVC
#sed "s/-tst/-${CLUSTER}/g" farmdoc-pvc.yaml | kubectl -n farmdoc apply -f -

# deploy
helm upgrade --install --namespace farmdoc --create-namespace farmdoc farmdoc  --values values-farmdoc-${CLUSTER}.yaml
