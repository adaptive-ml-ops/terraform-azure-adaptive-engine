# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains Terraform modules for deploying the Adaptive ML Ops infrastructure on Azure. The root module orchestrates four child modules to provision a complete environment including networking, Kubernetes, database, and authentication.

## Terraform Commands

### Initialize and Plan
```bash
terraform init
terraform plan
```

### Apply Changes
```bash
terraform apply
```

### Validate Configuration
```bash
terraform validate
terraform fmt -check -recursive
```

### Format Code
```bash
terraform fmt -recursive
```

### Destroy Infrastructure
```bash
terraform destroy
```

## Post-Deployment Commands

After Terraform deployment completes, several manual steps are required:

### Extract Terraform Outputs
```bash
# Get OIDC config for Helm chart (secrets.auth.oidc.providers)
terraform output -json out | jq -r .oidc_auth_config

# Get PostgreSQL connection string (secrets.dbUrl)
terraform output -json out | jq -r .postgres_connection_string

# Get resource group and cluster names
export RG=$(terraform output -json out | jq .resource_group_name)
export CLUSTER=$(terraform output out | jq .aks_cluster_name)
```

### Connect to AKS Cluster
```bash
az aks get-credentials -g ${RG} -n ${CLUSTER} --overwrite-existing
```

### Install NVIDIA GPU Operator
```bash
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update
helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator --version=v25.10.0
```

### Install Adaptive Helm Chart
Follow the Azure documentation at https://github.com/adaptive-ml/adaptive-helm-chart

## Architecture

### Module Structure

The infrastructure is composed of these modules in dependency order:

1. **Root Module** (`main.tf`) - Creates the resource group and orchestrates all child modules
2. **VNet Module** (`vnet/`) - Creates the virtual network with subnet carving logic
3. **AKS Module** (`aks/`) - Deploys the Kubernetes cluster with CPU and GPU node pools
4. **Postgres Module** (`postgres/`) - Provisions Azure PostgreSQL Flexible Server
5. **OIDC App Module** (`oidc_app/`) - Creates Azure AD application for authentication

### Key Architectural Patterns

**Subnet Carving**: The VNet module uses `cidrsubnets()` to automatically divide the provided VNET CIDR into two subnets (vnet/locals.tf:2):
- PostgreSQL subnet: First subnet with /8 extension (e.g., 10.0.0.0/22 from 10.0.0.0/14)
- AKS subnet: Second subnet with /2 extension (e.g., 10.0.4.0/16 from 10.0.0.0/14)

The VNET CIDR must be /14 or larger to accommodate this carving strategy (validated in variables.tf:38-40).

**Domain Extraction**: The root module extracts the domain from the hostname variable using regex (locals.tf:2):
```hcl
domain = regex("https://[^.]+\\.(.+)", var.hostname)[0]
```
This extracts the domain from a hostname like "https://adaptive.aks.example.com" → "aks.example.com"

**Module Dependencies**: Explicit `depends_on` relationships ensure proper creation order:
- Both AKS and PostgreSQL depend on VNet completion (main.tf:33, main.tf:59)
- PostgreSQL uses delegated subnet from VNet
- AKS has web app routing enabled with empty DNS zone list (aks/main.tf:36-38)

**Network Isolation**: PostgreSQL is configured with:
- Private DNS zone created by VNet module (e.g., `<deployment_name>.postgres.database.azure.com`)
- Delegated subnet with Microsoft.DBforPostgreSQL/flexibleServers delegation
- Public network access disabled (postgres/main.tf:13)
- Private DNS zone linked to the VNet for internal resolution

**High Availability**: PostgreSQL supports zone-redundant HA configuration:
- Configurable primary and secondary availability zones (variables.tf:94-117)
- Geo-redundant backups (default: enabled)
- High availability mode: ZoneRedundant (default), SameZone, or None

### Required Variables

Variables with no defaults that must be provided:
- `location` - Azure region
- `hostname` - Full hostname in format "https://<url>" (e.g., "https://adaptive.aks.example.com")
- `cidr_vnet` - VNET CIDR block (must be /14 or larger, e.g., "10.0.0.0/14")
- `gpu_node_pool_vm_size` - VM size for GPU nodes (e.g., "Standard_ND96isr_H200_v5")
- `gpu_node_count` - Number of GPU nodes (used for both min and max count in autoscaling)

### Module Outputs

**Root Module** exports:
- `postgres_connection_string` - Full PostgreSQL connection string (sensitive)
- `oidc_auth_config` - YAML-encoded OIDC configuration for Helm chart (sensitive)
- `resource_group_name` - Name of the created resource group
- `aks_cluster_name` - Name of the AKS cluster

**VNet Module** exports:
- `vnet_id` - Virtual network ID
- `k8s_subnet` - AKS subnet ID
- `postgres_subnet` - PostgreSQL subnet ID
- `postgres_dns_zone` - Private DNS zone ID for PostgreSQL

**AKS Module** exports:
- `cluster_name` - Name of the AKS cluster
- `kube_config` - Raw kubeconfig (sensitive, not exposed in root outputs)

**PostgreSQL Module** exports:
- `connection_string` - PostgreSQL connection string with credentials
- `server_fqdn` - Fully qualified domain name of the server
- `database_name` - Name of the created database

**OIDC Module** exports:
- `issuer_url` - OIDC issuer URL
- `client_id` - Azure AD application client ID
- `client_secret` - Application client secret (sensitive)

## Provider Requirements

- Terraform >= 1.10.0
- AzureRM provider ~> 4.0
- AzureAD provider (used in oidc_app module)
- Random provider ~> 3.0 (used in postgres module for password generation)
