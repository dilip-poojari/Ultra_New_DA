#!/bin/bash

##############################################################################
# Validation script for OpenShift AI on ROKS Deployable Architecture
##############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Counters
PASSED=0
FAILED=0
WARNINGS=0

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  OpenShift AI on ROKS - Validation Script                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print test result
print_result() {
    local test_name=$1
    local result=$2
    local message=$3
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} ${test_name}"
        ((PASSED++))
    elif [ "$result" = "FAIL" ]; then
        echo -e "${RED}✗${NC} ${test_name}"
        if [ -n "$message" ]; then
            echo -e "  ${RED}Error: ${message}${NC}"
        fi
        ((FAILED++))
    elif [ "$result" = "WARN" ]; then
        echo -e "${YELLOW}⚠${NC} ${test_name}"
        if [ -n "$message" ]; then
            echo -e "  ${YELLOW}Warning: ${message}${NC}"
        fi
        ((WARNINGS++))
    fi
}

echo -e "${YELLOW}Running validation checks...${NC}"
echo ""

# Check 1: Terraform installed
echo "1. Checking Terraform installation..."
if command -v terraform &> /dev/null; then
    TF_VERSION=$(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
    print_result "Terraform installed (version: ${TF_VERSION})" "PASS"
else
    print_result "Terraform installed" "FAIL" "Terraform not found in PATH"
fi

# Check 2: Required files exist
echo ""
echo "2. Checking required files..."
REQUIRED_FILES=(
    "main.tf"
    "variables.tf"
    "outputs.tf"
    "versions.tf"
    "provider.tf"
    "locals.tf"
    "README.md"
    "ARCHITECTURE.md"
    "ibm_catalog.json"
    ".gitignore"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "${ROOT_DIR}/${file}" ]; then
        print_result "File exists: ${file}" "PASS"
    else
        print_result "File exists: ${file}" "FAIL" "File not found"
    fi
done

# Check 3: Module structure
echo ""
echo "3. Checking module structure..."
MODULES=(
    "modules/vpc"
    "modules/networking"
    "modules/roks-cluster"
    "modules/odf-storage"
    "modules/openshift-ai"
    "modules/observability"
)

for module in "${MODULES[@]}"; do
    if [ -d "${ROOT_DIR}/${module}" ]; then
        # Check for required module files
        if [ -f "${ROOT_DIR}/${module}/main.tf" ] && \
           [ -f "${ROOT_DIR}/${module}/variables.tf" ] && \
           [ -f "${ROOT_DIR}/${module}/outputs.tf" ] && \
           [ -f "${ROOT_DIR}/${module}/versions.tf" ]; then
            print_result "Module complete: ${module}" "PASS"
        else
            print_result "Module complete: ${module}" "FAIL" "Missing required files"
        fi
    else
        print_result "Module exists: ${module}" "FAIL" "Module directory not found"
    fi
done

# Check 4: Examples
echo ""
echo "4. Checking examples..."
if [ -d "${ROOT_DIR}/examples/basic" ]; then
    if [ -f "${ROOT_DIR}/examples/basic/main.tf" ] && \
       [ -f "${ROOT_DIR}/examples/basic/variables.tf" ] && \
       [ -f "${ROOT_DIR}/examples/basic/outputs.tf" ] && \
       [ -f "${ROOT_DIR}/examples/basic/README.md" ]; then
        print_result "Basic example complete" "PASS"
    else
        print_result "Basic example complete" "FAIL" "Missing required files"
    fi
else
    print_result "Basic example exists" "FAIL" "Example directory not found"
fi

# Check 5: Terraform syntax validation
echo ""
echo "5. Validating Terraform syntax..."
cd "${ROOT_DIR}"
if terraform init -backend=false > /dev/null 2>&1; then
    if terraform validate > /dev/null 2>&1; then
        print_result "Terraform syntax valid" "PASS"
    else
        print_result "Terraform syntax valid" "FAIL" "Validation errors found"
    fi
else
    print_result "Terraform initialization" "FAIL" "Failed to initialize"
fi

# Check 6: JSON syntax validation
echo ""
echo "6. Validating JSON files..."
if command -v jq &> /dev/null; then
    if jq empty "${ROOT_DIR}/ibm_catalog.json" 2>/dev/null; then
        print_result "ibm_catalog.json syntax valid" "PASS"
    else
        print_result "ibm_catalog.json syntax valid" "FAIL" "Invalid JSON syntax"
    fi
else
    print_result "JSON validation" "WARN" "jq not installed, skipping JSON validation"
fi

# Check 7: Scripts are executable
echo ""
echo "7. Checking script permissions..."
SCRIPTS=(
    "scripts/create-tgz.sh"
    "scripts/validate.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "${ROOT_DIR}/${script}" ]; then
        if [ -x "${ROOT_DIR}/${script}" ]; then
            print_result "Script executable: ${script}" "PASS"
        else
            print_result "Script executable: ${script}" "WARN" "Not executable, run: chmod +x ${script}"
        fi
    else
        print_result "Script exists: ${script}" "FAIL" "Script not found"
    fi
done

# Check 8: Documentation completeness
echo ""
echo "8. Checking documentation..."
if grep -q "OpenShift AI on ROKS" "${ROOT_DIR}/README.md" 2>/dev/null; then
    print_result "README.md has content" "PASS"
else
    print_result "README.md has content" "FAIL" "README appears empty or invalid"
fi

if grep -q "Architecture Overview" "${ROOT_DIR}/ARCHITECTURE.md" 2>/dev/null; then
    print_result "ARCHITECTURE.md has content" "PASS"
else
    print_result "ARCHITECTURE.md has content" "FAIL" "ARCHITECTURE.md appears empty or invalid"
fi

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Validation Summary                                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}Passed:${NC}   ${PASSED}"
echo -e "  ${RED}Failed:${NC}   ${FAILED}"
echo -e "  ${YELLOW}Warnings:${NC} ${WARNINGS}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ Please review warnings above${NC}"
    fi
    echo ""
    echo "The Deployable Architecture is ready for:"
    echo "  • Creating .tgz archive (run: ./scripts/create-tgz.sh)"
    echo "  • Pushing to GitHub"
    echo "  • Importing to IBM Cloud Private Catalog"
    exit 0
else
    echo -e "${RED}✗ Validation failed with ${FAILED} error(s)${NC}"
    echo ""
    echo "Please fix the errors above before proceeding."
    exit 1
fi

# Made with Bob
