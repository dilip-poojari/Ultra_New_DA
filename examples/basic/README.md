# Basic Example - OpenShift AI on ROKS

This example demonstrates a basic deployment of OpenShift AI on Red Hat OpenShift on IBM Cloud (ROKS).

## Architecture

This example deploys:
- VPC with 3 subnets across 3 availability zones
- Public gateways for internet access
- ROKS cluster with 2 worker nodes per zone (6 total)
- OpenShift Data Foundation (ODF) for storage
- OpenShift AI with all components enabled
- No observability integration (can be added)

## Prerequisites

1. IBM Cloud account with appropriate permissions
2. IBM Cloud API key
3. Resource group created
4. Terraform >= 1.3.0 installed

## Usage

1. Create a `terraform.tfvars` file:

```hcl
ibmcloud_api_key  = "your-api-key-here"
region            = "us-south"
resource_group_id = "your-resource-group-id"
prefix            = "my-openshift-ai"
tags              = ["terraform", "openshift-ai", "dev"]
```

2. Initialize Terraform:

```bash
terraform init
```

3. Review the plan:

```bash
terraform plan
```

4. Apply the configuration:

```bash
terraform apply
```

## Deployment Time

Expected deployment time: **60-90 minutes**

- VPC and networking: 5 minutes
- ROKS cluster: 30-45 minutes
- ODF installation: 15-20 minutes
- OpenShift AI: 10-15 minutes

## Accessing OpenShift AI

After deployment completes:

1. Get the cluster configuration:
```bash
ibmcloud oc cluster config --cluster <cluster-name>
```

2. Access the OpenShift console:
```bash
oc get routes -n openshift-console
```

3. Access OpenShift AI dashboard:
```bash
oc get routes -n redhat-ods-operator
```

## Costs

Estimated monthly costs (us-south region):
- ROKS cluster (6 x bx2.16x64): ~$2,400/month
- VPC infrastructure: ~$50/month
- ODF storage: ~$200/month
- **Total: ~$2,650/month**

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: Ensure all PVCs and data are backed up before destroying.

## Customization

You can customize the deployment by modifying variables:

- `worker_pool_flavor`: Change worker node size
- `workers_per_zone`: Adjust number of workers
- `openshift_version`: Use different OpenShift version
- `enable_observability`: Enable IBM Cloud Logs and Monitoring

## Support

For issues or questions:
- Review the main [README](../../README.md)
- Check [ARCHITECTURE.md](../../ARCHITECTURE.md)
- Open an issue in the repository