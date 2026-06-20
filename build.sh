#!/usr/bin/env bash
# Vercel build script — downloads Flutter, builds Flutter web app.
# Runs inside Vercel's build container (Amazon Linux 2 / Node.js env).
set -euo pipefail

FLUTTER_VERSION="3.29.3"
FLUTTER_TAR="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter-infra-release/releases/stable/linux/${FLUTTER_TAR}"
FLUTTER_DIR="$HOME/flutter"

echo "==> Checking for Flutter..."
if [ ! -d "$FLUTTER_DIR/bin" ]; then
  echo "==> Downloading Flutter ${FLUTTER_VERSION}..."
  curl -fsSL "$FLUTTER_URL" -o /tmp/flutter.tar.xz
  echo "==> Extracting Flutter..."
  tar xf /tmp/flutter.tar.xz -C "$HOME"
  rm /tmp/flutter.tar.xz
else
  echo "==> Flutter already present at $FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --no-analytics --no-cli-animations
flutter --version

echo "==> Installing pub dependencies..."
cd chronos
flutter pub get

echo "==> Building Flutter web (release)..."
flutter build web --release --no-tree-shake-icons

echo "==> Build complete. Output: chronos/build/web"
