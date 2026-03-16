# OpenShift AI on ROKS - Deployable Architecture

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.3.0-blue)](https://www.terraform.io)
[![IBM Cloud](https://img.shields.io/badge/IBM%20Cloud-Deployable%20Architecture-blue)](https://cloud.ibm.com)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A comprehensive Deployable Architecture for deploying **Red Hat OpenShift AI (RHODS)** on **Red Hat OpenShift on IBM Cloud (ROKS)** with complete infrastructure automation.

## 🎯 Overview

This Deployable Architecture provides an enterprise-ready solution for deploying OpenShift AI on IBM Cloud, including:

- **VPC Infrastructure**: Isolated multi-zone VPC with subnets, NAT, and security groups
- **ROKS Cluster**: High-availability OpenShift cluster across 3 zones
- **Storage**: OpenShift Data Foundation (ODF) for persistent storage
- **OpenShift AI**: Complete AI/ML platform with notebooks, model serving, and pipelines
- **Observability**: Optional IBM Cloud Logs and Monitoring integration

## 🏗️ Architecture

### Components

```
┌─────────────────────────────────────────────────────────────┐
│                        IBM Cloud VPC                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Zone 1    │  │   Zone 2    │  │   Zone 3    │        │
│  │  ┌───────┐  │  │  ┌───────┐  │  │  ┌───────┐  │        │
│  │  │Subnet │  │  │  │Subnet │  │  │  │Subnet │  │        │
│  │  │Workers│  │  │  │Workers│  │  │  │Workers│  │        │
│  │  └───────┘  │  │  └───────┘  │  │  └───────┘  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Red Hat OpenShift Cluster (ROKS)           │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │      OpenShift Data Foundation (ODF)           │  │  │
│  │  │  • Block Storage (RBD)                         │  │  │
│  │  │  • File Storage (CephFS)                       │  │  │
│  │  │  • Object Storage (RGW)                        │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │         Red Hat OpenShift AI (RHODS)           │  │  │
│  │  │  • JupyterHub & Notebooks                      │  │  │
│  │  │  • Model Serving (KServe/ModelMesh)            │  │  │
│  │  │  • Data Science Pipelines                      │  │  │
│  │  │  • Model Registry                              │  │  │
│  │  │  • Ray, CodeFlare, Kueue                       │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Storage Decision: OpenShift Data Foundation (ODF)

**Why ODF over Portworx?**

1. **Native Integration**: ODF is Red Hat's official storage solution for OpenShift
2. **Cost-Effective**: Included in OpenShift subscription, no additional licensing
3. **Multi-Protocol**: Provides block, file, and object storage in one solution
4. **AI/ML Optimized**: Excellent performance for notebook PVs and model storage
5. **Operator-Based**: Consistent management through OpenShift operators
6. **Flexibility**: Supports both local and cloud-native storage backends

## 📋 Prerequisites

- IBM Cloud account with appropriate permissions
- IBM Cloud API key
- Resource group created
- Terraform >= 1.3.0
- IBM Cloud CLI (optional, for cluster access)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/dilip-poojari/Ultra_New_DA.git
cd Ultra_New_DA
```

### 2. Configure Variables

Create a `terraform.tfvars` file:

```hcl
ibmcloud_api_key  = "your-api-key-here"
region            = "us-south"
resource_group_id = "your-resource-group-id"
prefix            = "my-openshift-ai"

# Optional: Customize deployment
openshift_version  = "4.14_openshift"
worker_pool_flavor = "bx2.16x64"
workers_per_zone   = 2

# Optional: Enable observability
enable_observability      = true
log_analysis_instance_id  = "your-log-analysis-instance-id"
monitoring_instance_id    = "your-monitoring-instance-id"
```

### 3. Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 4. Access OpenShift AI

After deployment (60-90 minutes):

```bash
# Get cluster configuration
ibmcloud oc cluster config --cluster <cluster-name>

# Access OpenShift console
oc get routes -n openshift-console

# Access OpenShift AI dashboard
oc get routes -n redhat-ods-operator
```

## 📁 Repository Structure

```
.
├── main.tf                      # Root module configuration
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── versions.tf                  # Provider versions
├── provider.tf                  # Provider configuration
├── locals.tf                    # Local values
├── ibm_catalog.json            # IBM Cloud Catalog metadata
├── README.md                    # This file
├── ARCHITECTURE.md              # Detailed architecture documentation
├── modules/
│   ├── vpc/                    # VPC module
│   ├── networking/             # Networking module (subnets, gateways, SGs)
│   ├── roks-cluster/           # ROKS cluster module
│   ├── odf-storage/            # OpenShift Data Foundation module
│   ├── openshift-ai/           # OpenShift AI module
│   └── observability/          # Observability module (optional)
├── examples/
│   └── basic/                  # Basic deployment example
└── scripts/
    ├── create-tgz.sh           # Script to create .tgz for Private Catalog
    └── validate.sh             # Validation script
```

## 🔧 Configuration

### Required Variables

| Variable | Description | Type |
|----------|-------------|------|
| `ibmcloud_api_key` | IBM Cloud API key | string |
| `region` | IBM Cloud region | string |
| `resource_group_id` | Resource group ID | string |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `prefix` | Resource name prefix | `openshift-ai` |
| `openshift_version` | OpenShift version | `4.14_openshift` |
| `worker_pool_flavor` | Worker node flavor | `bx2.16x64` |
| `workers_per_zone` | Workers per zone | `2` |
| `enable_observability` | Enable monitoring | `false` |

See [variables.tf](./variables.tf) for complete list.

## 📊 Outputs

| Output | Description |
|--------|-------------|
| `cluster_id` | OpenShift cluster ID |
| `cluster_name` | OpenShift cluster name |
| `cluster_ingress_hostname` | Cluster ingress hostname |
| `openshift_ai_dashboard_url` | OpenShift AI dashboard URL |
| `deployment_summary` | Complete deployment summary |

## 💰 Cost Estimation

Estimated monthly costs (us-south region):

| Component | Configuration | Monthly Cost |
|-----------|--------------|--------------|
| ROKS Cluster | 6 x bx2.16x64 workers | ~$2,400 |
| VPC Infrastructure | 3 zones, subnets, gateways | ~$50 |
| ODF Storage | 512GB per zone | ~$200 |
| **Total** | | **~$2,650** |

*Costs vary by region and configuration. Use IBM Cloud Cost Estimator for accurate pricing.*

## ⏱️ Deployment Time

- **VPC & Networking**: 5 minutes
- **ROKS Cluster**: 30-45 minutes
- **ODF Installation**: 15-20 minutes
- **OpenShift AI**: 10-15 minutes
- **Total**: **60-90 minutes**

## 🔒 Security Features

- VPC network isolation
- Security groups with restrictive rules
- Optional KMS encryption for cluster
- ODF storage encryption
- OpenShift RBAC controls
- Private service endpoints support

## 📈 High Availability

- Multi-zone deployment (3 zones)
- Multiple worker nodes per zone
- ODF data replication across zones
- IBM Cloud Load Balancer for ingress
- Automatic pod rescheduling

## 🔍 Observability

Optional integration with:
- **IBM Cloud Logs**: Centralized logging
- **IBM Cloud Monitoring**: Metrics and dashboards
- **OpenShift Monitoring**: Built-in Prometheus/Grafana
- **ServiceMonitors**: Custom metrics for OpenShift AI

## 📚 Documentation

- [Architecture Details](./ARCHITECTURE.md)
- [Basic Example](./examples/basic/README.md)
- [IBM Cloud Docs - ROKS](https://cloud.ibm.com/docs/openshift)
- [Red Hat OpenShift AI Docs](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai)

## 🛠️ IBM Cloud Private Catalog

### Importing to Private Catalog

1. Create a `.tgz` archive:
```bash
./scripts/create-tgz.sh
```

2. Upload to IBM Cloud Object Storage

3. Import to Private Catalog:
   - Go to IBM Cloud Console → Catalog → Private Catalogs
   - Create or select a catalog
   - Add offering → Import from repository
   - Provide the GitHub URL or Object Storage URL

4. Configure and publish

### Catalog Metadata

The `ibm_catalog.json` file contains all metadata required for Private Catalog integration, including:
- Product information
- Configuration parameters
- IAM permissions
- Compliance profiles
- Architecture diagrams

## 🧪 Validation

Run validation checks:

```bash
./scripts/validate.sh
```

This checks:
- Terraform syntax
- Module structure
- Required files
- Metadata format

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## 🆘 Support

For issues or questions:
- Open an issue in this repository
- Review the [ARCHITECTURE.md](./ARCHITECTURE.md) documentation
- Check IBM Cloud documentation
- Contact IBM Cloud support

## 🔄 Updates and Maintenance

This Deployable Architecture is maintained to support:
- Latest OpenShift versions
- Latest OpenShift AI releases
- IBM Cloud platform updates
- Security patches and improvements

## 📞 Contact

- **Repository**: https://github.com/dilip-poojari/Ultra_New_DA
- **Issues**: https://github.com/dilip-poojari/Ultra_New_DA/issues

## 🙏 Acknowledgments

- Red Hat for OpenShift and OpenShift AI
- IBM Cloud for ROKS platform
- Terraform community
- Contributors and users

---

**Note**: This is a production-ready Deployable Architecture. Always review and test in a non-production environment before deploying to production.