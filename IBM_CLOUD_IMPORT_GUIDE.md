# IBM Cloud Private Catalog - Exact Import Steps

## Current Repository Status
- **Repository**: https://github.com/dilip-poojari/Ultra_New_DA
- **Latest Release**: v1.0.1
- **Structure**: Terraform files at root level ✅
- **Metadata**: ibm_catalog.json present ✅

## Step-by-Step Import Instructions

### Step 1: Access IBM Cloud Private Catalog

1. Log in to IBM Cloud: https://cloud.ibm.com
2. Click on **Catalog** in the top navigation
3. Click on **Private catalogs** in the left sidebar
4. If you don't have a catalog, click **Create catalog**
   - Name: `My Deployable Architectures`
   - Description: `Custom deployable architectures`
   - Click **Create**

### Step 2: Add Product to Catalog

1. In your Private Catalog, click **Add product** (or **Add** button)
2. You'll see a form with these fields:

### Step 3: Fill in the Form EXACTLY as shown

**Repository type**: Select `Public repository`

**Source URL**: Use ONE of these formats (try in this order):

#### Option 1: Direct Repository URL (Try this first)
```
https://github.com/dilip-poojari/Ultra_New_DA
```

#### Option 2: Release Tag URL
```
https://github.com/dilip-poojari/Ultra_New_DA/releases/tag/v1.0.1
```

#### Option 3: Archive URL
```
https://github.com/dilip-poojari/Ultra_New_DA/archive/refs/tags/v1.0.1.tar.gz
```

#### Option 4: Git Clone URL
```
https://github.com/dilip-poojari/Ultra_New_DA.git
```

### Step 4: Additional Fields (if prompted)

- **Version**: `1.0.1` or leave blank
- **Variation**: `standard`
- **Terraform version**: `1.3` or higher

### Step 5: Click Import/Add

The system should now:
1. Access the repository
2. Parse the `ibm_catalog.json` file
3. Validate the Terraform code
4. Create the offering in your catalog

## If You Still Get an Error

### Troubleshooting Steps:

#### 1. Verify Repository is Public

Visit: https://github.com/dilip-poojari/Ultra_New_DA/settings

Ensure "Visibility" shows "Public"

#### 2. Test Repository Access

Open these URLs in your browser to verify they're accessible:

- Main repo: https://github.com/dilip-poojari/Ultra_New_DA
- Catalog file: https://raw.githubusercontent.com/dilip-poojari/Ultra_New_DA/main/ibm_catalog.json
- Main Terraform: https://raw.githubusercontent.com/dilip-poojari/Ultra_New_DA/main/main.tf

All should load without errors.

#### 3. Alternative: Use IBM Cloud CLI

If the UI continues to fail, use the CLI:

```bash
# Install IBM Cloud CLI if not already installed
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Login
ibmcloud login --apikey YOUR_API_KEY

# Target your account
ibmcloud target -r us-south

# Create offering from GitHub
ibmcloud catalog offering create \
  --catalog-id YOUR_CATALOG_ID \
  --zipurl https://github.com/dilip-poojari/Ultra_New_DA/archive/refs/tags/v1.0.1.tar.gz
```

#### 4. Alternative: Use Schematics Directly

Skip Private Catalog and deploy directly with Schematics:

```bash
# Create workspace
ibmcloud schematics workspace new \
  --name openshift-ai-roks \
  --type terraform_v1.5 \
  --location us-south \
  --resource-group Default \
  --github-url https://github.com/dilip-poojari/Ultra_New_DA \
  --github-branch main

# Get workspace ID from output, then:
ibmcloud schematics workspace get --id WORKSPACE_ID

# Generate plan
ibmcloud schematics plan --id WORKSPACE_ID

# Apply
ibmcloud schematics apply --id WORKSPACE_ID
```

## Alternative: Manual .tgz Upload

If GitHub import continues to fail:

### Step 1: Create Archive Locally

```bash
cd /Users/dilipbpoojari/Documents/Code/Ultra\ New\ DA
./scripts/create-tgz.sh
```

This creates: `dist/openshift-ai-roks-da-1.0.0.tgz`

### Step 2: Upload to IBM Cloud Object Storage

```bash
# Create bucket (one-time)
ibmcloud cos bucket-create \
  --bucket openshift-ai-deployable-arch \
  --region us-south \
  --class standard

# Upload archive
ibmcloud cos upload \
  --bucket openshift-ai-deployable-arch \
  --key openshift-ai-roks-da-1.0.1.tgz \
  --file dist/openshift-ai-roks-da-1.0.0.tgz \
  --region us-south
```

### Step 3: Import from Object Storage

1. In Private Catalog, click **Add product**
2. Select **Object Storage** as source
3. Choose your bucket: `openshift-ai-deployable-arch`
4. Select file: `openshift-ai-roks-da-1.0.1.tgz`
5. Click **Import**

## What IBM Cloud Expects

The repository MUST have:

1. ✅ **Terraform files at root level**
   - main.tf
   - variables.tf
   - outputs.tf
   - versions.tf
   - provider.tf

2. ✅ **ibm_catalog.json at root level**
   - Valid JSON format
   - Correct schema

3. ✅ **Valid Terraform syntax**
   - `terraform validate` passes

4. ✅ **Public repository** (or proper authentication for private)

5. ✅ **Release tags** (recommended but not required)

## Our Repository Status

All requirements are met:

```
✅ Terraform files at root: YES
✅ ibm_catalog.json present: YES
✅ Valid JSON: YES
✅ Valid Terraform: YES
✅ Public repository: YES
✅ Release tags: YES (v1.0.0, v1.0.1)
```

## Common Error Messages and Solutions

### "The source URL is formatted incorrectly"

**Solution**: Try different URL formats listed in Step 3 above

### "Authentication error"

**Solution**: Verify repository is public at https://github.com/dilip-poojari/Ultra_New_DA/settings

### "Error processing content"

**Solution**: Run validation locally:
```bash
cd /Users/dilipbpoojari/Documents/Code/Ultra\ New\ DA
terraform init
terraform validate
```

### "No valid Terraform found"

**Solution**: Ensure `working_directory` in ibm_catalog.json is set to `.` (root)

## Support Resources

- **IBM Cloud Docs**: https://cloud.ibm.com/docs/sell
- **Terraform Registry**: https://registry.terraform.io/
- **Repository**: https://github.com/dilip-poojari/Ultra_New_DA
- **Issues**: https://github.com/dilip-poojari/Ultra_New_DA/issues

## Quick Test

Before importing, test the repository structure:

```bash
# Clone and validate
git clone https://github.com/dilip-poojari/Ultra_New_DA.git
cd Ultra_New_DA
terraform init
terraform validate

# Should output: Success! The configuration is valid.
```

## Next Steps After Successful Import

1. **Validate** the offering in Private Catalog
2. **Configure** required parameters
3. **Test deploy** in a test environment
4. **Publish** to your account
5. **Share** with team members

---

**Last Updated**: 2026-03-16  
**Repository**: https://github.com/dilip-poojari/Ultra_New_DA  
**Latest Release**: v1.0.1