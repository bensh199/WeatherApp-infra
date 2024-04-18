#!/bin/bash

region="<your region>"
cluster_name="<your cluster name>"
account_ID="<your account ID>"

# Delete Argo CD
helm uninstall my-argo-cd --namespace argocd

# Delete Argo CD namespace
kubectl delete namespace argocd

# Delete AWS Load Balancer Controller
helm uninstall aws-load-balancer-controller -n kube-system

# Delete AWS Load Balancer Controller IAM Policy
aws iam delete-policy --policy-arn arn:aws:iam::"$account_ID":policy/AWSLoadBalancerControllerIAMPolicy

# Delete EBS CSI Controller Service Account
eksctl delete iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster "$cluster_name"

# Delete AWS Load Balancer Controller Service Account
eksctl delete iamserviceaccount \
    --name aws-load-balancer-controller \
    --namespace kube-system \
    --cluster "$cluster_name"

eksctl delete iamserviceaccount \
    --name external-dns \
    --namespace default \
    --cluster "$cluster_name"

kubectl -n argocd delete -f /Users/ben/Documents/WeatherApp-EKS-Helm/ArgoCD/Ingress-service.yaml
    
echo "Cleanup completed."