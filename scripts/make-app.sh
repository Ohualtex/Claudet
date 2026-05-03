#!/usr/bin/env bash
# Build the Claudet.app bundle in build/.
# Doing this lets macOS treat us as a real app: stable bundle ID,
# proper Dock/agent behavior, and visibility to screenshot allowlists.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

build_dir="${CLAUDET_BUILD_DIR:-/tmp/claudet-build}"
app_dir="$(pwd)/build/Claudet.app"

echo "→ Compiling release binary…"
swift build -c release --build-path "$build_dir" >/dev/null

echo "→ Assembling bundle at $app_dir"
rm -rf "$app_dir"
mkdir -p "$app_dir/Contents/MacOS"
mkdir -p "$app_dir/Contents/Resources"
cp "$build_dir/release/claudet" "$app_dir/Contents/MacOS/Claudet"

cat > "$app_dir/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>Claudet</string>
  <key>CFBundleIdentifier</key><string>desktop.claudet.pet</string>
  <key>CFBundleName</key><string>Claudet</string>
  <key>CFBundleDisplayName</key><string>Claude&apos;t</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSUIElement</key><true/>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSSupportsAutomaticTermination</key><false/>
</dict>
</plist>
PLIST

# Re-stamp signature so Launch Services picks up the bundle id cleanly.
codesign --force --sign - "$app_dir" >/dev/null 2>&1 || true

# Tell Launch Services about the app so screenshot allowlists & open -a work.
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -f "$app_dir" 2>/dev/null || true

echo "✓ Built: $app_dir"
echo "  Launch with: open '$app_dir'"
