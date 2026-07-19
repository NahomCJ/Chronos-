#!/usr/bin/env bash
# Vercel build script — clones Flutter stable and builds the Flutter web app.
set -euo pipefail

FLUTTER_DIR="$HOME/flutter"

echo "==> Checking for Flutter..."
if [ ! -d "$FLUTTER_DIR/bin" ]; then
  echo "==> Cloning Flutter (stable)..."
  git clone https://github.com/flutter/flutter.git \
    --branch stable --depth 1 "$FLUTTER_DIR"
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
