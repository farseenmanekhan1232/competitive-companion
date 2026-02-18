#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Safari Extension GitHub Secrets Setup ===${NC}"
echo "This script will help you set up the required secrets for building the Safari extension."
echo "Prerequisite: You must have exported your Apple Distribution Certificate (.p12) and Provisioning Profile."
echo ""

# Check for gh CLI
if ! command -v gh &> /dev/null; then
    echo "Error: 'gh' CLI is not installed or not in PATH."
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    echo "Error: You are not logged into gh. Please run 'gh auth login' first."
    exit 1
fi

# Get the repository from the 'origin' remote (handles ssh and https)
REPO=$(git remote get-url origin | sed -E 's/.*github.com[:/](.*).git/\1/')

if [ -z "$REPO" ]; then
    echo "Error: Could not detect repository from 'origin' remote."
    exit 1
fi
echo -e "Target Repository: ${GREEN}$REPO${NC}"
echo ""

# 1. MACOS_CERTIFICATE_PWD
echo -e "${YELLOW}1. Enter the password for your .p12 Certificate file:${NC}"
read -s CERT_PWD
gh secret set MACOS_CERTIFICATE_PWD --body "$CERT_PWD" -R "$REPO"
echo -e "${GREEN}✓ MACOS_CERTIFICATE_PWD set.${NC}"
echo ""

# 2. MACOS_CERTIFICATE
echo -e "${YELLOW}2. Drag and drop your .p12 Certificate file here (then press Enter):${NC}"
read CERT_PATH
# Remove quotes and whitespace if dragged
CERT_PATH=$(echo "$CERT_PATH" | tr -d "'\"" | xargs)

if [ ! -f "$CERT_PATH" ]; then
    echo "Error: File not found at $CERT_PATH"
    exit 1
fi

echo "Encoding and uploading certificate..."
base64 < "$CERT_PATH" | gh secret set MACOS_CERTIFICATE -R "$REPO"
echo -e "${GREEN}✓ MACOS_CERTIFICATE set.${NC}"
echo ""

# 3. PROVISIONING_PROFILE_BASE64
echo -e "${YELLOW}3. Drag and drop your .mobileprovision file here (then press Enter):${NC}"
read PROVISION_PATH
# Remove quotes and whitespace
PROVISION_PATH=$(echo "$PROVISION_PATH" | tr -d "'\"" | xargs)

if [ ! -f "$PROVISION_PATH" ]; then
    echo "Error: File not found at $PROVISION_PATH"
    exit 1
fi

echo "Encoding and uploading provisioning profile..."
base64 < "$PROVISION_PATH" | gh secret set PROVISIONING_PROFILE_BASE64 -R "$REPO"
echo -e "${GREEN}✓ PROVISIONING_PROFILE_BASE64 set.${NC}"
echo ""

# 4. KEYCHAIN_PASSWORD (Random)
echo -e "${YELLOW}4. Generating random Keychain Password...${NC}"
RANDOM_PASS=$(openssl rand -base64 24)
gh secret set KEYCHAIN_PASSWORD --body "$RANDOM_PASS" -R "$REPO"
echo -e "${GREEN}✓ KEYCHAIN_PASSWORD set.${NC}"
echo ""

echo -e "${GREEN}=== All Secrets Configured Successfully! ===${NC}"
echo "You can now push a tag (e.g., v2.64.0-safari) to trigger the release workflow."
