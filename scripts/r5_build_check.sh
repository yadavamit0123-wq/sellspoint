#!/usr/bin/env bash
# R5 local build verification — run on a machine with Flutter SDK installed.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: flutter not in PATH. Install Flutter 3.8+ and retry."
  exit 1
fi

echo "== flutter pub get =="
flutter pub get

echo "== flutter analyze =="
flutter analyze

echo "== android debug APK (optional smoke build) =="
flutter build apk --debug

echo ""
echo "R5 build check passed. Run on device: flutter run"
echo "Then: python3 scripts/smoke_admin_api.py"
