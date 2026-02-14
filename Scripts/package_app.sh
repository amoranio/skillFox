#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CONF="${1:-release}"
swift build -c "$CONF"

APP_ICON_SOURCE="${SKILLFOX_APP_ICON:-$ROOT/Icons/3.png}"
APP_ICON_ICNS="$ROOT/Icon.icns"

if [[ -f "$APP_ICON_SOURCE" ]]; then
  ICONSET_DIR="$(mktemp -d)"
  mkdir -p "$ICONSET_DIR/Icon.iconset"
  ICONSET="$ICONSET_DIR/Icon.iconset"

  sips -z 16 16 "$APP_ICON_SOURCE" --out "$ICONSET/icon_16x16.png" >/dev/null
  sips -z 32 32 "$APP_ICON_SOURCE" --out "$ICONSET/icon_16x16@2x.png" >/dev/null
  sips -z 32 32 "$APP_ICON_SOURCE" --out "$ICONSET/icon_32x32.png" >/dev/null
  sips -z 64 64 "$APP_ICON_SOURCE" --out "$ICONSET/icon_32x32@2x.png" >/dev/null
  sips -z 128 128 "$APP_ICON_SOURCE" --out "$ICONSET/icon_128x128.png" >/dev/null
  sips -z 256 256 "$APP_ICON_SOURCE" --out "$ICONSET/icon_128x128@2x.png" >/dev/null
  sips -z 256 256 "$APP_ICON_SOURCE" --out "$ICONSET/icon_256x256.png" >/dev/null
  sips -z 512 512 "$APP_ICON_SOURCE" --out "$ICONSET/icon_256x256@2x.png" >/dev/null
  sips -z 512 512 "$APP_ICON_SOURCE" --out "$ICONSET/icon_512x512.png" >/dev/null
  sips -z 1024 1024 "$APP_ICON_SOURCE" --out "$ICONSET/icon_512x512@2x.png" >/dev/null

  iconutil -c icns "$ICONSET" -o "$APP_ICON_ICNS"
  rm -rf "$ICONSET_DIR"
fi

HOST_ARCH="$(uname -m)"
BIN_CANDIDATES=(
  ".build/${HOST_ARCH}-apple-macosx/${CONF}/Skillfox"
  ".build/${CONF}/Skillfox"
)
BUNDLE_CANDIDATES=(
  ".build/${HOST_ARCH}-apple-macosx/${CONF}/Skillfox_Skillfox.bundle"
  ".build/${CONF}/Skillfox_Skillfox.bundle"
)

BIN_PATH=""
for candidate in "${BIN_CANDIDATES[@]}"; do
  if [[ -f "$candidate" ]]; then
    BIN_PATH="$candidate"
    break
  fi
done

if [[ -z "$BIN_PATH" ]]; then
  echo "Could not find built Skillfox binary." >&2
  exit 1
fi

BUNDLE_PATH=""
for candidate in "${BUNDLE_CANDIDATES[@]}"; do
  if [[ -d "$candidate" ]]; then
    BUNDLE_PATH="$candidate"
    break
  fi
done

APP="$ROOT/Skillfox.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$BIN_PATH" "$APP/Contents/MacOS/Skillfox"
if [[ -n "$BUNDLE_PATH" ]]; then
  cp -R "$BUNDLE_PATH" "$APP/Contents/Resources/"
fi
if [[ -f "$APP_ICON_ICNS" ]]; then
  cp "$APP_ICON_ICNS" "$APP/Contents/Resources/Icon.icns"
fi

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>Skillfox</string>
    <key>CFBundleDisplayName</key><string>Skillfox</string>
    <key>CFBundleIdentifier</key><string>com.skillfox.app</string>
    <key>CFBundleExecutable</key><string>Skillfox</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>CFBundleIconFile</key><string>Icon</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

echo "Created $APP"
