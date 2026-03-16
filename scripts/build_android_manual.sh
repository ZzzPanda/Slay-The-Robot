#!/bin/bash
set -e

# Slay-The-Robot Android Build Script (Manual Method)
# Usage: ./scripts/build_android_manual.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Set Android SDK
export ANDROID_HOME=/Users/roger/Android
export ANDROID_SDK_ROOT=/Users/roger/Android

# Timestamp for filename
TIMESTAMP=$(date +%Y%m%d_%H%M)
BUILD_DIR="builds/android"

echo "=== Slay-The-Robot Android Build (Manual) ==="
echo "Timestamp: $TIMESTAMP"

# Create build directory
mkdir -p "$BUILD_DIR"

# Step 1: Export pck
echo "[1/4] Exporting pck..."
godot --headless --export-pack "Android" "$BUILD_DIR/game.pck"

# Step 2: Extract template and replace pck
echo "[2/4] Building APK..."
cd "$BUILD_DIR"
rm -rf tmp_apk
mkdir -p tmp_apk
cd tmp_apk
unzip -q ~/.local/share/godot/export_templates/4.6.1.stable/android_release.apk
cp ../game.pck assets/game.pck
zip -rq ../game.apk .

# Step 3: Sign
echo "[3/4] Signing APK..."
cd "$BUILD_DIR"
~/Library/Android/sdk/build-tools/33.0.1/apksigner sign \
  --ks ~/.android/debug.keystore \
  --ks-key-alias androiddebugkey \
  --ks-pass pass:android \
  --key-pass pass:android \
  --out "Slay-the-robot-${TIMESTAMP}.apk" \
  game.apk

# Step 4: Copy to Google Drive
echo "[4/4] Copying to Google Drive..."
cp "Slay-the-robot-${TIMESTAMP}.apk" "/Users/roger/Google 云端硬盘/apk/Slay-The-Robot/android_debug_${TIMESTAMP}.apk"

# Cleanup
rm -rf tmp_apk game.pck game.apk

# Clean up old APKs (keep latest 5)
"$SCRIPT_DIR/cleanup_apk.sh"

echo ""
echo "=== Build Complete ==="
echo "APK: Slay-the-robot-${TIMESTAMP}.apk"
ls -lh "Slay-the-robot-${TIMESTAMP}.apk"
