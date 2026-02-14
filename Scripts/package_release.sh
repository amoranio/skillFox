#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${1:-1.0.0}"
ARCH="$(uname -m)"
DIST_DIR="$ROOT/dist"

./Scripts/package_app.sh release

mkdir -p "$DIST_DIR"

ZIP_PATH="$DIST_DIR/Skillfox-v${VERSION}-macos-${ARCH}.zip"
DMG_PATH="$DIST_DIR/Skillfox-v${VERSION}-macos-${ARCH}.dmg"
rm -f "$ZIP_PATH" "$ZIP_PATH.sha256" "$DMG_PATH" "$DMG_PATH.sha256"

ditto -c -k --keepParent "$ROOT/Skillfox.app" "$ZIP_PATH"

DMG_STAGING="$(mktemp -d)"
cp -R "$ROOT/Skillfox.app" "$DMG_STAGING/"
hdiutil create -volname "Skillfox" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_PATH" >/dev/null
rm -rf "$DMG_STAGING"

shasum -a 256 "$ZIP_PATH" > "$ZIP_PATH.sha256"
shasum -a 256 "$DMG_PATH" > "$DMG_PATH.sha256"

echo "Created:"
echo "  $ZIP_PATH"
echo "  $ZIP_PATH.sha256"
echo "  $DMG_PATH"
echo "  $DMG_PATH.sha256"
