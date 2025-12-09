#!/bin/bash
# Restore script for persistent data on Mint Linux USB

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Mint Linux USB Persistent Data Restore ===${NC}"
echo -e "${RED}WARNING: This will restore data and may overwrite existing files!${NC}"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should NOT be run as root${NC}"
   exit 1
fi

# Get backup source
read -p "Enter backup source path (e.g., /media/mint/EXTERNAL_DRIVE/backup): " BACKUP_SOURCE

if [ ! -d "$BACKUP_SOURCE" ]; then
    echo -e "${RED}Error: Backup source does not exist${NC}"
    exit 1
fi

# Look for backup info file
if [ -f "$BACKUP_SOURCE/backup_info.txt" ]; then
    echo -e "${BLUE}Backup information found:${NC}"
    cat "$BACKUP_SOURCE/backup_info.txt"
    echo ""
fi

# Show what will be restored
echo -e "${YELLOW}Contents of backup:${NC}"
if [ -d "$BACKUP_SOURCE/home" ]; then
    echo "✓ Home directory data found"
    echo "  Size: $(du -sh "$BACKUP_SOURCE/home" 2>/dev/null | cut -f1)"
    ls -la "$BACKUP_SOURCE/home" | head -10
fi

if [ -d "$BACKUP_SOURCE/system_etc" ]; then
    echo "✓ System configuration found"
    echo "  Size: $(du -sh "$BACKUP_SOURCE/system_etc" 2>/dev/null | cut -f1)"
fi

echo ""

# Multiple confirmation prompts
read -p "Step 1/2: Do you want to continue with this backup source? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

read -p "Step 2/2: This will OVERWRITE existing files. Are you SURE? (type YES): " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "Restore cancelled."
    exit 0
fi

# Create timestamped backup of current state (safety net)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SAFETY_BACKUP="/tmp/safety_backup_$TIMESTAMP"

echo -e "${YELLOW}Creating safety backup of current home directory...${NC}"
mkdir -p "$SAFETY_BACKUP"
cp -r /home/mint/* "$SAFETY_BACKUP/" 2>/dev/null || true
echo "Safety backup created at: $SAFETY_BACKUP"
echo ""

# Restore home directory
if [ -d "$BACKUP_SOURCE/home" ]; then
    echo -e "${GREEN}Restoring home directory...${NC}"
    rsync -av --progress --exclude='.cache/*' "$BACKUP_SOURCE/home/" /home/mint/

    # Restore specific directories that were excluded during backup
    if [ -d "$BACKUP_SOURCE/home/.cache" ]; then
        echo "Restoring cache directory..."
        rsync -av --progress "$BACKUP_SOURCE/home/.cache/" /home/mint/.cache/
    fi

    echo -e "${GREEN}Home directory restored.${NC}"
else
    echo -e "${RED}No home directory data found in backup.${NC}"
fi

# Restore system configurations (optional, requires sudo)
if [ -d "$BACKUP_SOURCE/system_etc" ]; then
    echo ""
    read -p "Restore system configurations? (requires sudo) (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Restoring system configurations...${NC}"
        sudo rsync -av --progress "$BACKUP_SOURCE/system_etc/" /etc/
        echo -e "${GREEN}System configurations restored.${NC}"
    fi
fi

# Fix permissions
echo -e "${YELLOW}Fixing file permissions...${NC}"
sudo chown -R mint:mint /home/mint/
chmod -R 755 /home/mint/

# Show restore summary
echo ""
echo -e "${GREEN}=== Restore Summary ===${NC}"
echo "✓ Home directory restored from: $BACKUP_SOURCE/home"
echo "✓ File permissions fixed"
if [ -d "$BACKUP_SOURCE/system_etc" ]; then
    echo "✓ System configurations available (restored if selected)"
fi
echo ""
echo -e "${BLUE}Safety backup of original data: $SAFETY_BACKUP${NC}"
echo -e "${YELLOW}You may want to delete this after verifying the restore worked.${NC}"
echo ""
echo -e "${GREEN}Restore completed! Please reboot to ensure all changes take effect.${NC}"

# Optional cleanup prompt
echo ""
read -p "Delete safety backup now? (recommended after testing) (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$SAFETY_BACKUP"
    echo "Safety backup deleted."
else
    echo "Safety backup kept at: $SAFETY_BACKUP"
fi
