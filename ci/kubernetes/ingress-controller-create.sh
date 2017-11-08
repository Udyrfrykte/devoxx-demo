#! /bin/bash
kubectl apply -f ingress-controller/ingress-controller-404.yaml
kubectl apply -f ingress-controller/ingress-controller-rc.yaml
kubectl apply -f ingress-controller/ingress-controller-svc.yaml
