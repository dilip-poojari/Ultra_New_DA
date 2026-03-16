#!/bin/bash

##############################################################################
# Script to create .tgz archive for IBM Cloud Private Catalog
##############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Output configuration
OUTPUT_DIR="${ROOT_DIR}/dist"
ARCHIVE_NAME="openshift-ai-roks-da"
VERSION="${VERSION:-1.0.0}"
FULL_ARCHIVE_NAME="${ARCHIVE_NAME}-${VERSION}.tgz"

echo -e "${GREEN}Creating IBM Cloud Private Catalog archive...${NC}"
echo "Root directory: ${ROOT_DIR}"
echo "Output directory: ${OUTPUT_DIR}"
echo "Archive name: ${FULL_ARCHIVE_NAME}"
echo ""

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Create temporary directory for staging
TEMP_DIR=$(mktemp -d)
STAGING_DIR="${TEMP_DIR}/${ARCHIVE_NAME}"
mkdir -p "${STAGING_DIR}"

echo -e "${YELLOW}Staging files...${NC}"

# Copy required files and directories
cp -r "${ROOT_DIR}/modules" "${STAGING_DIR}/"
cp -r "${ROOT_DIR}/examples" "${STAGING_DIR}/"
cp "${ROOT_DIR}/main.tf" "${STAGING_DIR}/"
cp "${ROOT_DIR}/variables.tf" "${STAGING_DIR}/"
cp "${ROOT_DIR}/outputs.tf" "${STAGING_DIR}/"
cp "${ROOT_DIR}/versions.tf" "${STAGING_DIR}/"
cp "${ROOT_DIR}/provider.tf" "${STAGING_DIR}/"
cp "${ROOT_DIR}/locals.tf" "${STAGING_DIR}/"
cp "${ROOT_DIR}/README.md" "${STAGING_DIR}/"
cp "${ROOT_DIR}/ARCHITECTURE.md" "${STAGING_DIR}/"
cp "${ROOT_DIR}/ibm_catalog.json" "${STAGING_DIR}/"
cp "${ROOT_DIR}/.gitignore" "${STAGING_DIR}/"

# Create version file
echo "${VERSION}" > "${STAGING_DIR}/VERSION"

# Create metadata file
cat > "${STAGING_DIR}/METADATA.json" << EOF
{
  "name": "${ARCHIVE_NAME}",
  "version": "${VERSION}",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "description": "OpenShift AI on ROKS Deployable Architecture",
  "terraform_version": ">=1.3.0",
  "providers": {
    "ibm": ">=1.63.0",
    "kubernetes": ">=2.23.0",
    "helm": ">=2.11.0"
  }
}
EOF

echo -e "${YELLOW}Cleaning up unnecessary files...${NC}"

# Remove any .terraform directories
find "${STAGING_DIR}" -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true

# Remove any .tfstate files
find "${STAGING_DIR}" -type f -name "*.tfstate*" -delete 2>/dev/null || true

# Remove any .tfvars files (they may contain sensitive data)
find "${STAGING_DIR}" -type f -name "*.tfvars" -delete 2>/dev/null || true

# Remove any backup files
find "${STAGING_DIR}" -type f -name "*.backup" -delete 2>/dev/null || true
find "${STAGING_DIR}" -type f -name "*.bak" -delete 2>/dev/null || true

# Remove any log files
find "${STAGING_DIR}" -type f -name "*.log" -delete 2>/dev/null || true

# Remove .DS_Store files (macOS)
find "${STAGING_DIR}" -type f -name ".DS_Store" -delete 2>/dev/null || true

echo -e "${YELLOW}Creating archive...${NC}"

# Create the archive
cd "${TEMP_DIR}"
tar -czf "${OUTPUT_DIR}/${FULL_ARCHIVE_NAME}" "${ARCHIVE_NAME}"

# Calculate checksum
cd "${OUTPUT_DIR}"
CHECKSUM=$(shasum -a 256 "${FULL_ARCHIVE_NAME}" | awk '{print $1}')

# Create checksum file
echo "${CHECKSUM}  ${FULL_ARCHIVE_NAME}" > "${FULL_ARCHIVE_NAME}.sha256"

# Get archive size
ARCHIVE_SIZE=$(du -h "${FULL_ARCHIVE_NAME}" | awk '{print $1}')

# Cleanup
rm -rf "${TEMP_DIR}"

echo ""
echo -e "${GREEN}✓ Archive created successfully!${NC}"
echo ""
echo "Archive details:"
echo "  Location: ${OUTPUT_DIR}/${FULL_ARCHIVE_NAME}"
echo "  Size: ${ARCHIVE_SIZE}"
echo "  SHA256: ${CHECKSUM}"
echo ""
echo "Next steps:"
echo "  1. Upload to IBM Cloud Object Storage:"
echo "     ibmcloud cos upload --bucket <bucket-name> --key ${FULL_ARCHIVE_NAME} --file ${OUTPUT_DIR}/${FULL_ARCHIVE_NAME}"
echo ""
echo "  2. Import to Private Catalog:"
echo "     - Go to IBM Cloud Console → Catalog → Private Catalogs"
echo "     - Select or create a catalog"
echo "     - Click 'Add offering'"
echo "     - Choose 'Import from repository' or 'Import from Object Storage'"
echo "     - Provide the URL or select the uploaded file"
echo ""
echo "  3. Or push to GitHub and import from repository:"
echo "     git add ."
echo "     git commit -m 'Release version ${VERSION}'"
echo "     git tag v${VERSION}"
echo "     git push origin main --tags"
echo ""

# Made with Bob
