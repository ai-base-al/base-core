#!/bin/bash
# Backup current build with a label

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BINARIES_DIR="$ROOT_DIR/binaries"
BACKUP_DIR="$BINARIES_DIR/backups"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}Backup Build${NC}"
echo ""

# Check if app exists
if [ ! -d "$BINARIES_DIR/Base Dev.app" ]; then
    echo -e "${YELLOW}No Base Dev.app found to backup${NC}"
    exit 1
fi

# Get label from user or use timestamp
LABEL="${1:-$(date +%Y%m%d-%H%M%S)}"
BACKUP_NAME="Base Dev.app.$LABEL"

mkdir -p "$BACKUP_DIR"

echo -e "${GREEN}Backing up:${NC} Base Dev.app"
echo -e "${GREEN}Label:${NC} $LABEL"
echo ""

cp -R "$BINARIES_DIR/Base Dev.app" "$BACKUP_DIR/$BACKUP_NAME"

echo -e "${GREEN}${BOLD}Backup saved!${NC}"
echo ""
echo -e "${BOLD}Location:${NC} binaries/backups/$BACKUP_NAME"
echo ""
echo -e "${BOLD}To restore:${NC} ./scripts/restore_build.sh $LABEL"
echo ""
