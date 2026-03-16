# Troubleshooting Guide - IBM Cloud Private Catalog Import

## Common Import Errors and Solutions

### Error: "The source URL is formatted incorrectly"

This error occurs when IBM Cloud cannot access or parse your GitHub repository.

#### Solution 1: Verify Repository Structure

IBM Cloud expects Terraform files at the **root level** of the repository:

```
✅ Correct Structure:
/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── provider.tf
├── modules/
└── ibm_catalog.json

❌ Incorrect Structure:
/
└── terraform/
    ├── main.tf
    └── ...
```

**Our repository is correctly structured with files at root level.**

#### Solution 2: Use Correct Import URL Format

When importing from GitHub, use one of these formats:

**Option A: HTTPS URL (Recommended)**
```
https://github.com/dilip-poojari/Ultra_New_DA
```

**Option B: Release Tag URL**
```
https://github.com/dilip-poojari/Ultra_New_DA/releases/tag/v1.0.0
```

**Option C: Archive URL**
```
https://github.com/dilip-poojari/Ultra_New_DA/archive/refs/tags/v1.0.0.tar.gz
```

#### Solution 3: Check Repository Visibility

Ensure the repository is **public**:
1. Go to https://github.com/dilip-poojari/Ultra_New_DA/settings
2. Scroll to "Danger Zone"
3. Verify visibility is set to "Public"

#### Solution 4: Verify ibm_catalog.json

The `ibm_catalog.json` must be valid and at the root level.

**Check our file:**
```bash
cd /Users/dilipbpoojari/Documents/Code/Ultra\ New\ DA
cat ibm_catalog.json | jq .
```

If `jq` is not installed:
```bash
python3 -m json.tool ibm_catalog.json
```

### Error: "Authentication error when accessing this URL"

#### Solution 1: For Private Repositories

If your repository is private, you need to provide authentication:

1. Create a Personal Access Token (PAT) in GitHub:
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Generate new token with `repo` scope
   - Copy the token

2. In IBM Cloud Private Catalog:
   - When adding offering, select "Private repository"
   - Provide the token in the authentication field

#### Solution 2: For Public Repositories

No authentication should be needed. If you still get this error:
- Verify the repository is truly public
- Try using the archive URL format instead
- Check if GitHub is experiencing issues: https://www.githubstatus.com/

### Error: "Error while processing the content returned by this URL"

This means IBM Cloud can access the repository but cannot parse the Terraform code.

#### Solution 1: Validate Terraform Syntax

```bash
cd /Users/dilipbpoojari/Documents/Code/Ultra\ New\ DA
terraform init
terraform validate
```

#### Solution 2: Check Required Files

Ensure these files exist at root level:
- ✅ `main.tf`
- ✅ `variables.tf`
- ✅ `outputs.tf`
- ✅ `versions.tf` or `version.tf`
- ✅ `provider.tf` (optional but recommended)

#### Solution 3: Verify Provider Configuration

Check `versions.tf` has correct format:

```hcl
terraform {
  required_version = ">= 1.3.0"
  
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.63.0"
    }
  }
}
```

### Error: "No valid Terraform configuration found"

#### Solution: Check Working Directory

In `ibm_catalog.json`, the `working_directory` should be:
- `.` for root level (our current setup)
- `examples/basic` for example directory

**Our configuration:**
```json
{
  "flavors": [
    {
      "working_directory": ".",
      ...
    }
  ]
}
```

## Step-by-Step Import Process

### Method 1: Direct GitHub Import (Recommended)

1. **Go to IBM Cloud Console**
   - Navigate to: https://cloud.ibm.com/catalog/content/private

2. **Create or Select Catalog**
   - Click "Create catalog" or select existing
   - Name: `My Deployable Architectures`

3. **Add Offering**
   - Click "Add offering"
   - Select "Import from repository"

4. **Configure Import**
   ```
   Repository type: Public repository
   Source URL: https://github.com/dilip-poojari/Ultra_New_DA
   Version: v1.0.0 (or leave blank for latest)
   ```

5. **Select Variation**
   - Choose "standard" variation
   - This uses the root directory configuration

6. **Validate**
   - Click "Validate"
   - Provide test values for required variables
   - Wait for validation to complete

7. **Publish**
   - Once validated, click "Publish to account"

### Method 2: Using .tgz Archive

If GitHub import fails, use the archive method:

1. **Create Archive**
   ```bash
   cd /Users/dilipbpoojari/Documents/Code/Ultra\ New\ DA
   ./scripts/create-tgz.sh
   ```

2. **Upload to Object Storage**
   ```bash
   # Create bucket
   ibmcloud cos bucket-create --bucket my-da-bucket --region us-south
   
   # Upload archive
   ibmcloud cos upload \
     --bucket my-da-bucket \
     --key openshift-ai-roks-da-1.0.0.tgz \
     --file dist/openshift-ai-roks-da-1.0.0.tgz
   ```

3. **Import from Object Storage**
   - In Private Catalog, click "Add offering"
   - Select "Import from Object Storage"
   - Choose your bucket and file
   - Continue with validation

### Method 3: Manual Validation

If automated import fails, validate manually:

1. **Clone Repository Locally**
   ```bash
   git clone https://github.com/dilip-poojari/Ultra_New_DA.git
   cd Ultra_New_DA
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Create terraform.tfvars**
   ```hcl
   ibmcloud_api_key  = "your-api-key"
   region            = "us-south"
   resource_group_id = "your-rg-id"
   prefix            = "test"
   ```

4. **Validate**
   ```bash
   terraform validate
   terraform plan
   ```

5. **If validation passes locally**, the issue is with the import process, not the code.

## Validation Checklist

Before importing to Private Catalog, verify:

- [ ] Repository is public and accessible
- [ ] All Terraform files are at root level
- [ ] `ibm_catalog.json` is valid JSON
- [ ] `terraform validate` passes locally
- [ ] No syntax errors in any `.tf` files
- [ ] All modules have required files (main.tf, variables.tf, outputs.tf, versions.tf)
- [ ] Provider versions are specified correctly
- [ ] No hardcoded values that should be variables
- [ ] README.md exists and is comprehensive

## Quick Validation Script

Run this to check everything:

```bash
cd /Users/dilipbpoojari/Documents/Code/Ultra\ New\ DA
./scripts/validate.sh
```

## Getting Help

If you continue to experience issues:

1. **Check IBM Cloud Status**
   - https://cloud.ibm.com/status

2. **Review IBM Cloud Documentation**
   - https://cloud.ibm.com/docs/sell?topic=sell-repo-upload-error

3. **Check Terraform Registry Format**
   - https://developer.hashicorp.com/terraform/registry/modules/publish

4. **Open Support Ticket**
   - https://cloud.ibm.com/unifiedsupport

5. **GitHub Issues**
   - https://github.com/dilip-poojari/Ultra_New_DA/issues

## Alternative: Use Schematics Workspace

If Private Catalog import continues to fail, you can deploy directly using Schematics:

1. **Create Schematics Workspace**
   ```bash
   ibmcloud schematics workspace new \
     --name openshift-ai-roks \
     --type terraform_v1.5 \
     --location us-south \
     --resource-group Default \
     --github-url https://github.com/dilip-poojari/Ultra_New_DA
   ```

2. **Generate Plan**
   ```bash
   ibmcloud schematics plan --id <workspace-id>
   ```

3. **Apply**
   ```bash
   ibmcloud schematics apply --id <workspace-id>
   ```

## Known Issues and Workarounds

### Issue: Large Repository Size

**Symptom**: Import times out or fails
**Solution**: Use .tgz archive method instead of direct GitHub import

### Issue: Module Path Resolution

**Symptom**: Modules not found during validation
**Solution**: Ensure module paths in `main.tf` use relative paths:
```hcl
module "vpc" {
  source = "./modules/vpc"  # ✅ Correct
  # source = "modules/vpc"  # ❌ May fail
}
```

### Issue: Provider Authentication

**Symptom**: Validation fails with authentication errors
**Solution**: Ensure API key has correct permissions:
- VPC Infrastructure: Editor
- Kubernetes Service: Administrator
- Resource Controller: Editor

## Success Indicators

You'll know the import succeeded when:
- ✅ Offering appears in your Private Catalog
- ✅ Validation completes without errors
- ✅ All variables are properly displayed
- ✅ Documentation is accessible
- ✅ You can create a Schematics workspace from the offering

## Contact

For additional support:
- **Repository**: https://github.com/dilip-poojari/Ultra_New_DA
- **Issues**: https://github.com/dilip-poojari/Ultra_New_DA/issues
- **Email**: Create an issue in the repository