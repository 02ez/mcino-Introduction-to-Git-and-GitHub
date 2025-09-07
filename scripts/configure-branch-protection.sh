#!/bin/bash
# Branch Protection Configuration Script
# Sets up enterprise-grade branch protection rules

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OWNER="${GITHUB_REPOSITORY_OWNER:-02ez}"
REPO="${GITHUB_REPOSITORY_NAME:-mcino-Introduction-to-Git-and-GitHub}"
BRANCH="${BRANCH_NAME:-main}"

echo -e "${BLUE}=== Branch Protection Configuration ===${NC}"
echo "Repository: ${OWNER}/${REPO}"
echo "Branch: ${BRANCH}"
echo ""

# Function to configure branch protection
configure_branch_protection() {
    echo -e "${GREEN}Configuring branch protection for ${BRANCH}...${NC}"
    
    # Check if gh CLI is available
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}GitHub CLI (gh) not found. Please install it first.${NC}"
        echo "Installation: https://cli.github.com/"
        return 1
    fi
    
    # Configure branch protection using GitHub CLI
    gh api repos/"${OWNER}"/"${REPO}"/branches/"${BRANCH}"/protection \
        --method PUT \
        --field required_status_checks='{"strict":true,"contexts":["build-test","security-scan","supply-chain"]}' \
        --field enforce_admins=true \
        --field required_pull_request_reviews='{"required_approving_review_count":2,"dismiss_stale_reviews":true,"require_code_owner_reviews":true,"require_last_push_approval":true}' \
        --field restrictions=null \
        --field allow_force_pushes=false \
        --field allow_deletions=false \
        --field block_creations=false \
        --field required_conversation_resolution=true || {
        
        echo -e "${RED}✗ Failed to configure branch protection${NC}"
        return 1
    }
    
    echo -e "${GREEN}✓ Branch protection configured successfully${NC}"
    return 0
}

# Function to configure repository settings
configure_repository_settings() {
    echo -e "${GREEN}Configuring repository settings...${NC}"
    
    # Enable security features
    gh api repos/"${OWNER}"/"${REPO}" \
        --method PATCH \
        --field security_and_analysis='{"secret_scanning":{"status":"enabled"},"secret_scanning_push_protection":{"status":"enabled"},"dependabot_security_updates":{"status":"enabled"},"private_vulnerability_reporting":{"status":"enabled"}}' || {
        
        echo -e "${YELLOW}⚠ Could not enable all security features (may require admin access)${NC}"
    }
    
    echo -e "${GREEN}✓ Repository settings configured${NC}"
}

# Function to display the configuration as JSON (for API calls)
display_configuration_json() {
    echo -e "${BLUE}Branch Protection Configuration (JSON):${NC}"
    cat << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "build-test",
      "security-scan", 
      "supply-chain"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 2,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "require_last_push_approval": true,
    "bypass_pull_request_allowances": {
      "users": [],
      "teams": [],
      "apps": []
    }
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true
}
EOF
}

# Function to display CLI commands
display_cli_commands() {
    echo -e "${BLUE}GitHub CLI Commands:${NC}"
    echo ""
    echo "# Configure branch protection:"
    echo "gh api repos/${OWNER}/${REPO}/branches/${BRANCH}/protection \\"
    echo "  --method PUT \\"
    echo "  --field required_status_checks='{\"strict\":true,\"contexts\":[\"build-test\",\"security-scan\",\"supply-chain\"]}' \\"
    echo "  --field enforce_admins=true \\"
    echo "  --field required_pull_request_reviews='{\"required_approving_review_count\":2,\"dismiss_stale_reviews\":true,\"require_code_owner_reviews\":true,\"require_last_push_approval\":true}' \\"
    echo "  --field restrictions=null \\"
    echo "  --field allow_force_pushes=false \\"
    echo "  --field allow_deletions=false \\"
    echo "  --field required_conversation_resolution=true"
    echo ""
    echo "# View current protection settings:"
    echo "gh api repos/${OWNER}/${REPO}/branches/${BRANCH}/protection"
    echo ""
    echo "# Enable security features:"
    echo "gh api repos/${OWNER}/${REPO} \\"
    echo "  --method PATCH \\"
    echo "  --field security_and_analysis='{\"secret_scanning\":{\"status\":\"enabled\"},\"secret_scanning_push_protection\":{\"status\":\"enabled\"},\"dependabot_security_updates\":{\"status\":\"enabled\"}}'"
}

# Function to verify current settings
verify_settings() {
    echo -e "${GREEN}Verifying current branch protection settings...${NC}"
    
    # Get current protection settings
    gh api repos/"${OWNER}"/"${REPO}"/branches/"${BRANCH}"/protection > /tmp/current_protection.json 2>/dev/null || {
        echo -e "${YELLOW}⚠ No branch protection currently configured${NC}"
        return 1
    }
    
    echo "Current settings:"
    cat /tmp/current_protection.json | jq '.'
    
    # Check required status checks
    REQUIRED_CHECKS=$(jq -r '.required_status_checks.contexts[]' /tmp/current_protection.json 2>/dev/null | tr '\n' ' ')
    echo "Required status checks: ${REQUIRED_CHECKS}"
    
    # Check review requirements
    REVIEW_COUNT=$(jq -r '.required_pull_request_reviews.required_approving_review_count' /tmp/current_protection.json 2>/dev/null)
    echo "Required reviews: ${REVIEW_COUNT}"
    
    # Check admin enforcement
    ENFORCE_ADMINS=$(jq -r '.enforce_admins.enabled' /tmp/current_protection.json 2>/dev/null)
    echo "Enforce for admins: ${ENFORCE_ADMINS}"
    
    rm -f /tmp/current_protection.json
}

# Main function
main() {
    echo -e "${BLUE}Setting up enterprise-grade branch protection...${NC}"
    echo ""
    
    case "${1:-configure}" in
        "configure")
            configure_branch_protection
            configure_repository_settings
            ;;
        "verify")
            verify_settings
            ;;
        "show-json")
            display_configuration_json
            ;;
        "show-commands")
            display_cli_commands
            ;;
        *)
            echo "Usage: $0 [configure|verify|show-json|show-commands]"
            echo ""
            echo "Commands:"
            echo "  configure     - Apply branch protection settings"
            echo "  verify        - Check current protection settings" 
            echo "  show-json     - Display configuration as JSON"
            echo "  show-commands - Display GitHub CLI commands"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}=== Branch Protection Requirements ===${NC}"
    echo "✓ Require pull request reviews (2 approvers minimum)"
    echo "✓ Require code owner reviews"
    echo "✓ Dismiss stale reviews when new commits are pushed"
    echo "✓ Require status checks to pass before merging"
    echo "✓ Require branches to be up to date before merging"
    echo "✓ Enforce restrictions for administrators"
    echo "✓ Restrict pushes and deletions"
    echo "✓ Require conversation resolution before merging"
    echo ""
    echo -e "${GREEN}Branch protection configuration completed!${NC}"
}

# Check if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi