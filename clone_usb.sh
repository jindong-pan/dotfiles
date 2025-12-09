#!/bin/bash
# Clone entire USB drive to another drive

echo "=== USB Drive Cloning Tool ==="
echo "WARNING: This will overwrite the target drive!"
echo ""

# List available drives
echo "Available drives:"
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL | grep -E '^sd|^nvme'
echo ""

# Get source and target
read -p "Enter source USB device (e.g., sdb): " SOURCE_DEV
read -p "Enter target USB device (e.g., sdc): " TARGET_DEV
read -p "Confirm target device $TARGET_DEV will be COMPLETELY ERASED (type YES): " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Aborting."
    exit 1
fi

echo "Starting clone from /dev/$SOURCE_DEV to /dev/$TARGET_DEV..."
echo "This may take a while..."

# Use ddrescue for reliable cloning
sudo ddrescue -f -v "/dev/$SOURCE_DEV" "/dev/$TARGET_DEV" clone.log

echo "Clone completed. Check clone.log for details."
