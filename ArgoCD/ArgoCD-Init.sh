#!/bin/bash

region=""
cluster_name=""
account_ID=""
Path_To_Root=""

while getopts r:c:a:p: flag
do
    case "${flag}" in
        r)  
            region=${OPTARG};;
        c)  
            cluster_name=${OPTARG};;
        a)  
            account_ID=${OPTARG};;
        p)  
            Path_To_Root=${OPTARG};;
        *)  
            echo "Invalid option: $1"
            exit 1;;
    esac
done
echo "Username: $username";
echo "Age: $age";
echo "Full Name: $fullname"; 

echo "$region"

echo "$cluster_name"

echo "$account_ID" 

echo "$Path_To_Root"


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


helm install my-argo-cd argo/argo-cd --version 6.7.3 --namespace argocd --values "$Path_To_Root"/WeatherApp-infra/ArgoCD/values.yaml

kubectl -n argocd apply -f "$Path_To_Root"/WeatherApp-infra/ArgoCD/Ingress-service.yaml

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

kubectl -n default apply -f "$Path_To_Root"/WeatherApp-infra/ArgoCD/External-DNS.yaml