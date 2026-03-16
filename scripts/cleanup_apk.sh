#!/bin/bash
# Clean up old APK files, keeping only the latest 5

APK_DIR="/Users/roger/openclaw/workspace/game/Slay-The-Robot/builds/android"
KEEP=5

echo "=== APK Cleanup ==="
echo "Keeping latest $KEEP versions..."

# Get list of APKs sorted by modification time (newest first)
cd "$APK_DIR"
APK_FILES=(*.apk)

if [ ${#APK_FILES[@]} -le $KEEP ]; then
    echo "Found ${#APK_FILES[@]} APKs, nothing to clean."
    exit 0
fi

# Calculate how many to delete
TOTAL=${#APK_FILES[@]}
TO_DELETE=$((TOTAL - KEEP))

echo "Found $TOTAL APKs, deleting $TO_DELETE old ones..."

# Delete old APKs (sorted alphabetically, oldest first)
COUNT=0
for apk in "${APK_FILES[@]}"; do
    if [ $COUNT -lt $TO_DELETE ]; then
        echo "  Deleting: $apk"
        rm -f "$apk"
        # Also delete corresponding .idsig file if exists
        rm -f "${apk}.idsig" 2>/dev/null
        ((COUNT++))
    else
        break
    fi
done

echo "Done! Remaining APKs:"
ls -lh *.apk 2>/dev/null | awk '{print $9, $5}'
