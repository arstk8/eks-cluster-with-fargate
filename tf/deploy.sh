rm -rf .terraform
rm .terraform.lock.hcl

terraform init
terraform apply

clusterName=kub-dep-demo
aws eks update-kubeconfig --region us-east-1 --name "$clusterName"
kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'

vpcId="$(aws eks describe-cluster --name $clusterName --query cluster.resourcesVpcConfig.vpcId --output text)"
kubectl apply -f=aws.yaml
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName="$clusterName" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId="$vpcId"
# TODO: check to see if this deployment actually gets scheduled with fargate