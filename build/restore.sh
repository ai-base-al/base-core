#!/bin/bash
# Restore a backed up build

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
echo -e "${CYAN}${BOLD}Restore Build${NC}"
echo ""

# List backups if no label provided
if [ -z "$1" ]; then
    echo -e "${BOLD}Available backups:${NC}"
    echo ""
    ls -1 "$BACKUP_DIR" | grep "Base Dev.app" | sed 's/Base Dev.app./  - /'
    echo ""
    echo -e "${BOLD}Usage:${NC} ./scripts/restore_build.sh <label>"
    echo ""
    exit 0
fi

LABEL="$1"
BACKUP_NAME="Base Dev.app.$LABEL"

if [ ! -d "$BACKUP_DIR/$BACKUP_NAME" ]; then
    echo -e "${YELLOW}Backup not found: $BACKUP_NAME${NC}"
    echo ""
    echo -e "${BOLD}Available backups:${NC}"
    ls -1 "$BACKUP_DIR" | grep "Base Dev.app" | sed 's/Base Dev.app./  - /'
    echo ""
    exit 1
fi

# Remove current build if exists
if [ -d "$BINARIES_DIR/Base Dev.app" ]; then
    echo -e "${YELLOW}Removing current Base Dev.app${NC}"
    rm -rf "$BINARIES_DIR/Base Dev.app"
fi

echo -e "${GREEN}Restoring:${NC} $LABEL"
echo ""

cp -R "$BACKUP_DIR/$BACKUP_NAME" "$BINARIES_DIR/Base Dev.app"

echo -e "${GREEN}${BOLD}Build restored!${NC}"
echo ""
echo -e "${BOLD}Run:${NC} open \"$BINARIES_DIR/Base Dev.app\""
echo ""
