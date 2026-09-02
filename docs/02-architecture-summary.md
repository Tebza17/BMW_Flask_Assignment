# Architecture Summary

## High-Level Design

1. Developer pushes code to repository
2. CI validates chart and container build
3. Deploy workflow authenticates to AWS with OIDC
4. Image is published to ECR
5. Helm deploys or upgrades workload in EKS
6. Service is exposed through Kubernetes LoadBalancer

## Runtime Responsibilities

- Flask app serves HTTP endpoints and optional Kafka interactions
- Kubernetes handles scheduling, scaling, and health probing
- Helm provides declarative release management

## Reliability Features

- Health probes in deployment
- Optional HPA for scaling
- PDB support for safer disruptions

## Where To Go Next

- [GitOps and Delivery Flow](03-gitops-delivery-flow.md)
- [Main Project Guide](../README.md)
