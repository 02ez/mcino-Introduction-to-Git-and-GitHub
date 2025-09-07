#!/bin/bash
# SBOM Generation and Verification Script
# Generates Software Bill of Materials for the financial calculators project

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
OUTPUT_DIR="${OUTPUT_DIR:-${PROJECT_DIR}/sbom-output}"
FORMATS=("json" "spdx-json" "cyclonedx-json" "table")

echo -e "${GREEN}=== SBOM Generation Script ===${NC}"
echo "Project Directory: ${PROJECT_DIR}"
echo "Output Directory: ${OUTPUT_DIR}"
echo ""

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Check if Syft is installed
if ! command -v syft &> /dev/null; then
    echo -e "${YELLOW}Installing Syft...${NC}"
    curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
fi

# Generate SBOM in multiple formats
echo -e "${GREEN}Generating SBOM in multiple formats...${NC}"
for format in "${FORMATS[@]}"; do
    echo -e "Generating ${format} format..."
    syft packages "dir:${PROJECT_DIR}" -o "${format}" > "${OUTPUT_DIR}/sbom.${format}"
    
    # Validate the generated file
    if [[ -s "${OUTPUT_DIR}/sbom.${format}" ]]; then
        echo -e "${GREEN}✓ Successfully generated SBOM in ${format} format${NC}"
    else
        echo -e "${RED}✗ Failed to generate SBOM in ${format} format${NC}"
        exit 1
    fi
done

# Generate checksums
echo -e "${GREEN}Generating checksums...${NC}"
cd "${OUTPUT_DIR}"
sha256sum sbom.* > sbom-checksums.sha256
echo -e "${GREEN}✓ Checksums generated${NC}"

# Display summary
echo ""
echo -e "${GREEN}=== SBOM Generation Summary ===${NC}"
echo "Files generated:"
ls -la "${OUTPUT_DIR}"/sbom.*

# Validate SBOM content
echo ""
echo -e "${GREEN}=== SBOM Validation ===${NC}"

# Check for required components
if jq -e '.artifacts | length > 0' "${OUTPUT_DIR}/sbom.json" > /dev/null 2>&1; then
    COMPONENT_COUNT=$(jq '.artifacts | length' "${OUTPUT_DIR}/sbom.json")
    echo -e "${GREEN}✓ SBOM contains ${COMPONENT_COUNT} components${NC}"
else
    echo -e "${RED}✗ SBOM validation failed - no components found${NC}"
    exit 1
fi

# List key components
echo ""
echo -e "${GREEN}Key Components:${NC}"
jq -r '.artifacts[] | select(.type == "python") | .name' "${OUTPUT_DIR}/sbom.json" | head -10

echo ""
echo -e "${GREEN}=== SBOM Commands for CI/CD ===${NC}"
echo "# Generate SBOM in CI/CD pipeline:"
echo "syft packages dir:. -o json > sbom.json"
echo "syft packages dir:. -o spdx-json > sbom-spdx.json"
echo "syft packages dir:. -o cyclonedx-json > sbom-cyclonedx.json"
echo ""
echo "# Validate SBOM:"
echo "jq '.artifacts | length' sbom.json"
echo "jq '.artifacts[].name' sbom.json"
echo ""
echo "# Generate checksums:"
echo "sha256sum sbom.* > sbom-checksums.sha256"

echo ""
echo -e "${GREEN}✓ SBOM generation completed successfully!${NC}"
echo "Output directory: ${OUTPUT_DIR}"