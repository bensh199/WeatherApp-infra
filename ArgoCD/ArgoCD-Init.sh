#!/bin/bash

region="<your region>"
cluster_name="<your cluster name>"
account_ID="<your account ID>"


echo "## Configuring kube config ##"

aws eks update-kubeconfig --region "$region" --name "$cluster_name"

echo "## Creating Service Account For The LoadBalancer Controller ##"

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.1/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

rm iam_policy.json

eksctl create iamserviceaccount \
    --cluster "$cluster_name" \
    --namespace kube-system \
    --name aws-load-balancer-controller \
    --role-name AmazonEKSLoadBalancerControllerRole \
    --attach-policy-arn arn:aws:iam::"$account_ID":policy/AWSLoadBalancerControllerIAMPolicy \
    --approve

sleep 15

helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName="$cluster_name" \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller

sleep 20

kubectl get deployment -n kube-system aws-load-balancer-controller

echo "## Deploying ArgoCD ##"

sleep 10

helm repo add argo https://argoproj.github.io/argo-helm

kubectl create namespace argocd


helm install my-argo-cd argo/argo-cd --version 6.7.3 --namespace argocd --values ./values.yaml

kubectl -n argocd apply -f ./Ingress-service.yaml

sleep 25

kubectl get pods -n argocd

eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster "$cluster_name" \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve

eksctl create iamserviceaccount \
    --name external-dns \
    --namespace default \
    --cluster "$cluster_name" \
    --attach-policy-arn arn:aws:iam::"$account_ID":policy/ExternalDNS \
    --approve

kubectl -n default apply -f ./External-DNS.yaml