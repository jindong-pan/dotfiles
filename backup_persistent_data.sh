#!/bin/bash
# Backup script for persistent data on Mint Linux USB

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Mint Linux USB Persistent Data Backup ===${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should NOT be run as root${NC}"
   exit 1
fi

# Get backup destination
read -p "Enter backup destination path (e.g., /media/mint/EXTERNAL_DRIVE/backup): " BACKUP_DEST

if [ ! -d "$BACKUP_DEST" ]; then
    echo -e "${RED}Error: Backup destination does not exist${NC}"
    exit 1
fi

# Check available space
echo -e "${YELLOW}Checking available space...${NC}"
BACKUP_SPACE=$(df -BG "$BACKUP_DEST" | tail -1 | awk '{print $4}' | sed 's/G//')
echo "Available space on backup drive: ${BACKUP_SPACE}GB"

# Estimate persistent data size
PERSISTENT_SIZE=$(du -BG /home/mint 2>/dev/null | tail -1 | awk '{print $1}' | sed 's/G//')
echo "Estimated data to backup: ~${PERSISTENT_SIZE}GB"

if [ "$PERSISTENT_SIZE" -gt "$BACKUP_SPACE" ]; then
    echo -e "${RED}Warning: Not enough space on backup drive!${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create backup directory with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_DEST/mint_backup_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

echo -e "${GREEN}Starting backup to: $BACKUP_DIR${NC}"

# Backup home directory (excluding cache and temp files)
rsync -av --progress --exclude='.cache/*' --exclude='.thumbnails/*' \
    --exclude='Downloads/*' --exclude='*.tmp' \
    /home/mint/ "$BACKUP_DIR/home/"

# Backup persistent system changes (if any custom configs)
sudo rsync -av --progress /etc/ "$BACKUP_DIR/system_etc/" 2>/dev/null || true

# Create backup info file
cat > "$BACKUP_DIR/backup_info.txt" << EOF
Mint Linux USB Backup Information
=================================
Backup Date: $(date)
Original System: Mint Linux Live USB with Ventoy
Backup Location: $BACKUP_DIR
Data Size: ~${PERSISTENT_SIZE}GB

To restore:
1. Boot from Mint Linux USB
2. Mount backup drive
3. Copy files back to /home/mint/
4. Reinstall any applications if needed

Excluded from backup:
- Cache directories (.cache, .thumbnails)
- Downloads folder
- Temporary files
EOF

echo -e "${GREEN}Backup completed successfully!${NC}"
echo "Backup location: $BACKUP_DIR"
echo "Total size: $(du -sh "$BACKUP_DIR" | cut -f1)"
