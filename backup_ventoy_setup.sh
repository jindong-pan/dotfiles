#!/bin/bash
# Backup Ventoy configuration and ISO files

echo "=== Ventoy Configuration Backup ==="

# Find the USB drive
USB_MOUNT=$(mount | grep ventoy | head -1 | awk '{print $3}')
if [ -z "$USB_MOUNT" ]; then
    echo "Ventoy USB not found. Please ensure USB is mounted."
    exit 1
fi

echo "USB mounted at: $USB_MOUNT"

# Get backup destination
read -p "Enter backup destination: " BACKUP_DEST

if [ ! -d "$BACKUP_DEST" ]; then
    mkdir -p "$BACKUP_DEST"
fi

# Backup Ventoy configuration
echo "Backing up Ventoy configuration..."
cp -r "$USB_MOUNT/ventoy/" "$BACKUP_DEST/" 2>/dev/null || true

# Backup ISOs
echo "Backing up ISO files..."
find "$USB_MOUNT" -name "*.iso" -exec cp {} "$BACKUP_DEST/" \;

# Backup persistent data if it exists
if [ -d "$USB_MOUNT/ventoy/ventoy_persistent" ]; then
    echo "Backing up persistent data..."
    cp -r "$USB_MOUNT/ventoy/ventoy_persistent" "$BACKUP_DEST/"
fi

echo "Backup completed to: $BACKUP_DEST"
