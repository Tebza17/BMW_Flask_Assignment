# Terraform (Bonus) - EKS Infrastructure

This folder is an optional starter to provision AWS EKS infrastructure with Terraform.

## Run

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

After apply, update kubeconfig:

```bash
aws eks update-kubeconfig --region <region> --name <cluster_name>
```

Then deploy app using Helm from `../helm/flask-kafka-app`.

## Why this helps

- Repeatable infrastructure
- Version-controlled infra changes
- Easier review and rollback strategy
