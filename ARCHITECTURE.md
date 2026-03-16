# OpenShift AI on ROKS - Deployable Architecture

## Architecture Overview

This Deployable Architecture deploys Red Hat OpenShift AI (RHODS) on Red Hat OpenShift on IBM Cloud (ROKS) with a complete VPC infrastructure.

## Component Structure

### 1. Infrastructure Layer
- **VPC Module**: Creates isolated VPC with multiple zones
- **Networking Module**: Subnets, NAT Gateway, Security Groups
- **Storage Module**: OpenShift Data Foundation (ODF) for persistent storage

### 2. Platform Layer
- **ROKS Cluster Module**: Multi-zone OpenShift cluster (latest version)
- **Cluster Configuration**: HA setup with worker pools

### 3. Application Layer
- **OpenShift AI Operator**: Installed via Operator Lifecycle Manager
- **Notebook Components**: JupyterHub and notebook servers
- **Model Serving**: KServe/ModelMesh for ML model deployment

### 4. Observability Layer (Optional)
- **IBM Cloud Logs**: Centralized logging
- **IBM Cloud Monitoring**: Metrics and dashboards

## Storage Decision: OpenShift Data Foundation (ODF)

**Chosen: ODF (OpenShift Data Foundation)**

### Justification:
1. **Native Integration**: ODF is Red Hat's storage solution, deeply integrated with OpenShift
2. **Multi-Protocol Support**: Provides block, file, and object storage
3. **AI/ML Workloads**: Better suited for notebook persistent volumes and model storage
4. **Operator-Based**: Managed through OpenShift operators, consistent with RHODS
5. **Cost-Effective**: No additional licensing beyond OpenShift subscription
6. **Flexibility**: Supports both local and cloud-native storage backends

### ODF vs Portworx Comparison:
- **ODF Advantages**: Native to OpenShift, included in subscription, simpler management
- **Portworx Advantages**: More enterprise features, better for multi-cloud
- **For RHODS**: ODF provides sufficient performance and features for AI/ML workloads

## Folder Structure

```
openshift-ai-roks-da/
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── roks-cluster/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── odf-storage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── openshift-ai/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── observability/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── examples/
│   ├── basic/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── complete/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── provider.tf
├── locals.tf
├── README.md
├── ARCHITECTURE.md
├── ibm_catalog.json
├── .gitignore
└── scripts/
    ├── create-tgz.sh
    └── validate.sh
```

## Deployment Flow

1. **VPC Creation**: Isolated network environment
2. **Networking Setup**: Subnets across 3 zones, NAT, security groups
3. **ROKS Deployment**: Multi-zone OpenShift cluster
4. **ODF Installation**: Storage operator and storage cluster
5. **OpenShift AI**: Operator installation and component configuration
6. **Observability**: Optional monitoring and logging integration

## High Availability

- **Multi-Zone**: Resources distributed across 3 availability zones
- **Worker Pools**: Multiple worker nodes per zone
- **Storage Replication**: ODF provides data replication
- **Load Balancing**: IBM Cloud Load Balancer for ingress

## Security

- **Network Isolation**: Private VPC with controlled egress
- **Security Groups**: Restrictive rules for cluster access
- **RBAC**: OpenShift role-based access control
- **Encryption**: Data encrypted at rest and in transit