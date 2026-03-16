# IBM Cloud Private Catalog Setup Guide

This guide provides step-by-step instructions for importing the OpenShift AI on ROKS Deployable Architecture into IBM Cloud Private Catalog.

## Prerequisites

- IBM Cloud account with appropriate permissions
- Access to create/manage Private Catalogs
- GitHub repository: https://github.com/dilip-poojari/Ultra_New_DA

## Method 1: Import from GitHub Repository (Recommended)

### Step 1: Access Private Catalog

1. Log in to IBM Cloud Console: https://cloud.ibm.com
2. Navigate to **Catalog** → **Private Catalogs**
3. Click **Create** to create a new catalog (or select an existing one)

### Step 2: Create Private Catalog (if needed)

1. **Name**: `OpenShift AI Solutions` (or your preferred name)
2. **Description**: `Deployable Architectures for OpenShift AI workloads`
3. **Resource group**: Select your resource group
4. Click **Create**

### Step 3: Add Offering from GitHub

1. In your Private Catalog, click **Add offering**
2. Select **Import from repository**
3. Configure the import:
   - **Repository type**: Public repository
   - **Repository URL**: `https://github.com/dilip-poojari/Ultra_New_DA`
   - **Release**: `v1.0.0` (or select latest)
   - **Variation**: `basic`
   - **Terraform version**: `1.3` or higher

4. Click **Add offering**

### Step 4: Configure Offering

1. **Product information**:
   - Name: `OpenShift AI on ROKS`
   - Category: `Developer tools` or `AI / Machine Learning`
   - Provider: Your organization name

2. **Version information**:
   - Version: `1.0.0`
   - Description: Add detailed description
   - Long description: Copy from README.md

3. **Support information**:
   - Support URL: `https://github.com/dilip-poojari/Ultra_New_DA/issues`
   - Documentation URL: `https://github.com/dilip-poojari/Ultra_New_DA/blob/main/README.md`

### Step 5: Validate

1. Click **Validate** to run validation checks
2. Provide required parameters:
   - IBM Cloud API key
   - Region
   - Resource group ID
   - Prefix

3. Review validation results
4. Fix any issues if validation fails

### Step 6: Publish

1. Once validation passes, click **Publish to account**
2. Select visibility:
   - **Private**: Only your account
   - **Restricted**: Specific accounts
   - **Public**: All IBM Cloud users (requires approval)

3. Click **Publish**

## Method 2: Import from .tgz Archive

### Step 1: Create .tgz Archive

```bash
cd /Users/dilipbpoojari/Documents/Code/Ultra\ New\ DA
./scripts/create-tgz.sh
```

This creates: `dist/openshift-ai-roks-da-1.0.0.tgz`

### Step 2: Upload to IBM Cloud Object Storage

```bash
# Create bucket (if needed)
ibmcloud cos bucket-create --bucket openshift-ai-da --region us-south

# Upload archive
ibmcloud cos upload \
  --bucket openshift-ai-da \
  --key openshift-ai-roks-da-1.0.0.tgz \
  --file dist/openshift-ai-roks-da-1.0.0.tgz
```

### Step 3: Import to Private Catalog

1. In Private Catalog, click **Add offering**
2. Select **Import from Object Storage**
3. Configure:
   - **Bucket**: Select your bucket
   - **Object**: Select the .tgz file
   - **Variation**: `basic`

4. Follow steps 4-6 from Method 1

## Method 3: Manual Upload

### Step 1: Download from GitHub

```bash
# Clone or download the repository
git clone https://github.com/dilip-poojari/Ultra_New_DA.git
cd Ultra_New_DA
```

### Step 2: Create Archive

```bash
./scripts/create-tgz.sh
```

### Step 3: Upload via Console

1. In Private Catalog, click **Add offering**
2. Select **Upload archive**
3. Drag and drop the .tgz file
4. Follow configuration steps

## Verification Checklist

After importing, verify the following:

- [ ] Offering appears in Private Catalog
- [ ] All modules are present
- [ ] Variables are correctly configured
- [ ] Outputs are defined
- [ ] Documentation is accessible
- [ ] Validation passes successfully
- [ ] Example configurations work

## Configuration Parameters

The following parameters will be available in the catalog:

### Required Parameters
- `ibmcloud_api_key`: IBM Cloud API key
- `region`: IBM Cloud region
- `resource_group_id`: Resource group ID
- `prefix`: Resource name prefix

### Optional Parameters
- `openshift_version`: OpenShift version (default: 4.14_openshift)
- `worker_pool_flavor`: Worker node flavor (default: bx2.16x64)
- `workers_per_zone`: Workers per zone (default: 2)
- `enable_observability`: Enable monitoring (default: false)
- `odf_version`: ODF version (default: 4.14.0)
- `odf_billing_type`: ODF billing type (default: advanced)

## IAM Permissions Required

Users deploying this architecture need:

### VPC Infrastructure
- `is.vpc.vpc.create`
- `is.subnet.subnet.create`
- `is.security-group.security-group.create`
- `is.public-gateway.public-gateway.create`

### Kubernetes Service
- `containers-kubernetes.cluster.create`
- `containers-kubernetes.cluster.operate`

### Resource Management
- `resource-controller.instance.create`
- `resource-controller.instance.update`

## Troubleshooting

### Issue: Validation Fails

**Solution**: Check the following:
1. API key has correct permissions
2. Resource group exists
3. Region is valid
4. All required parameters are provided

### Issue: Import Fails

**Solution**:
1. Verify GitHub repository is accessible
2. Check release tag exists (v1.0.0)
3. Ensure ibm_catalog.json is valid
4. Review Terraform syntax

### Issue: Deployment Fails

**Solution**:
1. Check IBM Cloud service status
2. Verify quota limits
3. Review Terraform logs
4. Check network connectivity

## Support

For issues or questions:
- GitHub Issues: https://github.com/dilip-poojari/Ultra_New_DA/issues
- Documentation: https://github.com/dilip-poojari/Ultra_New_DA/blob/main/README.md
- IBM Cloud Support: https://cloud.ibm.com/unifiedsupport

## Next Steps

After successful import:

1. **Test Deployment**: Deploy in a test environment
2. **Document Customizations**: Add organization-specific configurations
3. **Set Up CI/CD**: Automate validation and updates
4. **Train Users**: Provide training on deployment process
5. **Monitor Usage**: Track deployments and gather feedback

## Updates and Maintenance

To update the offering:

1. Create new release in GitHub
2. Tag with version number (e.g., v1.1.0)
3. In Private Catalog, click **Update version**
4. Select new release
5. Validate and publish

## Compliance and Security

This Deployable Architecture includes:
- VPC network isolation
- Security group configurations
- Optional KMS encryption
- RBAC controls
- Audit logging support

Ensure compliance with your organization's security policies before deployment.

---

**Last Updated**: 2026-03-16  
**Version**: 1.0.0  
**Repository**: https://github.com/dilip-poojari/Ultra_New_DA