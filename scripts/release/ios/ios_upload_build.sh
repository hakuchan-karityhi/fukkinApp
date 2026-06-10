#!/bin/bash
# 用途: iOS リリース用 IPA をビルドするスクリプト。
# IPA保存先world_sudoku/build/ios/ipa/
# 実行時に ios_version.txt の build number を +1 し、
# world_sudoku を release ビルド（ipa 出力）します。
# 使用例: ./scripts/ios/ios_upload_build.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
APP_DIR="$ROOT_DIR/world_sudoku"
VERSION_FILE="$ROOT_DIR/ios_version.txt"
RELEASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../load_env.sh
source "$RELEASE_DIR/load_env.sh"

# version.txt に保存してある番号を読み込み
VERSION_CODE=$(cat "$VERSION_FILE")
VERSION_NAME="1.0.0"

# +1 して保存し直し
NEW_VERSION_CODE=$((VERSION_CODE + 1))
echo "$NEW_VERSION_CODE" > "$VERSION_FILE"

echo "Building iOS with versionName=$VERSION_NAME and versionCode=$NEW_VERSION_CODE"

cd "$APP_DIR"

# iOS用AdMob IDは環境変数または dart-define で指定
# 本番IDは適宜変更してください
flutter build ipa \
  --release \
  --build-name=$VERSION_NAME \
  --build-number=$NEW_VERSION_CODE \
  --dart-define=ADMOB_IOS_BANNER_HOME_ID="${ADMOB_IOS_BANNER_HOME_ID:-}" \
  --dart-define=ADMOB_IOS_INTERSTITIAL_RESULT_ID="${ADMOB_IOS_INTERSTITIAL_RESULT_ID:-}"

echo ""
echo "Build completed!"
echo "IPA location: $APP_DIR/build/ios/ipa/*.ipa"
