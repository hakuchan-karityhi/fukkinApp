#!/bin/bash
# 用途: Android リリース用 AAB をビルドするスクリプト。
# 実行時に android_version.txt の build number を +1 し、
# world_sudoku を release ビルド（app bundle）します。
# Play へのアップロードは行いません。
# 使用例（リポジトリルートから）: ./scripts/android/android_release_build.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
APP_DIR="$ROOT_DIR/world_sudoku"
VERSION_FILE="$ROOT_DIR/android_version.txt"

VERSION_CODE=$(cat "$VERSION_FILE")
VERSION_NAME="1.0.0"

NEW_VERSION_CODE=$((VERSION_CODE + 1))
echo "$NEW_VERSION_CODE" > "$VERSION_FILE"

echo "Building with versionName=$VERSION_NAME and versionCode=$NEW_VERSION_CODE"

cd "$APP_DIR"
flutter build appbundle \
  --release \
  --build-name=$VERSION_NAME \
  --build-number=$NEW_VERSION_CODE \
  --dart-define=ADMOB_ANDROID_BANNER_HOME_ID=ca-app-pub-4552740243948731/1066396270 \
  --dart-define=ADMOB_ANDROID_INTERSTITIAL_RESULT_ID=ca-app-pub-4552740243948731/4158299751
