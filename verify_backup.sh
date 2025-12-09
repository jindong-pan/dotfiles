#!/bin/bash
# Verify backup integrity

echo "=== Backup Verification Tool ==="

read -p "Enter backup path to verify: " BACKUP_PATH

if [ ! -d "$BACKUP_PATH" ]; then
    echo "Error: Backup path does not exist"
    exit 1
fi

echo "Verifying backup at: $BACKUP_PATH"
echo "================================="

# Check for required directories
if [ -d "$BACKUP_PATH/home" ]; then
    echo "✓ Home directory: $(du -sh "$BACKUP_PATH/home" | cut -f1)"
    echo "  Files: $(find "$BACKUP_PATH/home" -type f | wc -l)"
else
    echo "✗ Home directory missing"
fi

if [ -d "$BACKUP_PATH/system_etc" ]; then
    echo "✓ System config: $(du -sh "$BACKUP_PATH/system_etc" | cut -f1)"
else
    echo "- System config: Not included (normal for basic backups)"
fi

if [ -f "$BACKUP_PATH/backup_info.txt" ]; then
    echo "✓ Backup info file found"
    echo "  Backup date: $(grep "Backup Date:" "$BACKUP_PATH/backup_info.txt" | cut -d: -f2-)"
else
    echo "✗ Backup info file missing"
fi

# Check for important files
echo ""
echo "Important files check:"
IMPORTANT_FILES=(
    ".bashrc"
    ".profile"
    "projects/pydroid_app"
    "projects/pydroid_app/main.py"
    "projects/pydroid_app/buildozer.spec"
)

for file in "${IMPORTANT_FILES[@]}"; do
    if [ -e "$BACKUP_PATH/home/$file" ]; then
        echo "✓ $file"
    else
        echo "- $file (not found)"
    fi
done

echo ""
echo "Backup verification complete!"
