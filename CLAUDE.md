# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains Terraform modules for deploying the Adaptive ML Ops infrastructure on Azure. The root module orchestrates five child modules to provision a complete environment including networking, Kubernetes, database, DNS, and authentication.

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

## Architecture

### Module Structure

The infrastructure is composed of these modules in dependency order:

1. **Root Module** (`main.tf`) - Creates the resource group and orchestrates all child modules
2. **VNet Module** (`vnet/`) - Creates the virtual network with subnet carving logic
3. **DNS Zone Module** (`dns_zone/`) - Manages the Azure DNS zone
4. **AKS Module** (`aks/`) - Deploys the Kubernetes cluster with CPU and GPU node pools
5. **Postgres Module** (`postgres/`) - Provisions Azure PostgreSQL Flexible Server
6. **OIDC App Module** (`oidc_app/`) - Creates Azure AD application for authentication

### Key Architectural Patterns

**Subnet Carving**: The VNet module uses `cidrsubnets()` to automatically divide the provided VNET CIDR into two subnets (vnet/locals.tf:2):
- PostgreSQL subnet: First subnet with /8 extension
- AKS subnet: Second subnet with /2 extension

**Domain Extraction**: The root module extracts the domain from the hostname variable using regex to configure DNS (locals.tf:2):
```hcl
domain = regex("https://[^.]+\\.(.+)", var.hostname)[0]
```

**Module Dependencies**: Explicit `depends_on` relationships ensure proper creation order:
- AKS depends on VNet completion
- PostgreSQL uses delegated subnet from VNet
- DNS zone is passed to AKS for web app routing

**Network Isolation**: PostgreSQL is configured with:
- Private DNS zone (e.g., `adaptive.postgres.database.azure.com`)
- Delegated subnet with service endpoint
- Public network access disabled
- DNS zone linked to the VNet

### Required Variables

When working with this codebase, note these variables have no defaults and must be provided:
- `location` - Azure region
- `cidr_vnet` - VNET CIDR block
- `cpu_node_pool_vm_size` - VM size for CPU nodes
- `gpu_node_pool_vm_size` - VM size for GPU nodes

### TODOs in Codebase

Several items marked TODO that may need attention:
- `postgres/main.tf:9-10` - Hardcoded PostgreSQL admin credentials need to be parameterized
- `outputs.tf:1-4` - Helm values output is not yet implemented
- `variables.tf:40` - CIDR validation not implemented
- `variables.tf:43` - CPU node pool VM size needs default value

### Module Outputs

**VNet Module** exports:
- `vnet_id` - Virtual network ID
- `k8s_subnet` - AKS subnet ID
- `postgres_subnet` - PostgreSQL subnet ID
- `postgres_dns_zone` - Private DNS zone ID

**AKS Module** exports sensitive outputs:
- `kube_config` - Raw kubeconfig (sensitive)
- `client_certificate` - Client cert for cluster access (sensitive)

**DNS Module** exports:
- `dns_zone` - The DNS zone ID (used for AKS web app routing)

## Provider Requirements

- Terraform >= 1.10.0
- AzureRM provider ~> 4.0
- AzureAD provider (used in oidc_app module)
