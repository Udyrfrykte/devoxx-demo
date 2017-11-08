#! /bin/bash

kubectl apply -f gitlab-runner/gitlab-runner-1-cm.yaml
sleep 1
kubectl apply -f gitlab-runner/gitlab-runner-1-deployment.yaml
sleep 1
bash -x gitlab-runner/gitlab-runner-registries-secrets.sh
