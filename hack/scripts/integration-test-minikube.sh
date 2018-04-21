#!/bin/bash

set -o errexit
set -o nounset

KUBERNETES_VERSION=${KUBERNETES_VERSION:-1.9.4}

SUDO=''
if [[ $(id -u) -ne 0 ]]
then
    SUDO="sudo"
fi

function cleanup {
    echo "=> Removing minikube cluster"
    $SUDO minikube delete
}
trap cleanup EXIT

echo "=> Preparing minikube for running integration tests"
$SUDO minikube start \
    --vm-driver=none \
    --feature-gates=CustomResourceSubresources=true \
    --kubernetes-version=${KUBERNETES_VERSION}

echo "=> Waiting for minikube to start"
sleep 30

# Hack for Travis. The kubeconfig has to be readable
if [[ -v TRAVIS ]]
then
    $SUDO chmod a+r ${HOME}/.kube/config
    $SUDO chmod a+r ${HOME}/.minikube/client.key
fi

echo "=> Running integration tests"
./integration-test.sh
