rm -rf .terraform
rm .terraform.lock.hcl

terraform init
terraform apply

aws eks update-kubeconfig --region us-east-1 --name kub-dep-demo
kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'