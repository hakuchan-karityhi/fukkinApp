#!/bin/bash
# 用途: 生成済み AAB を Google Play の指定トラックへアップロードするスクリプト。
# デフォルトは内部テスト（internal）。クローズドテストは alpha / beta 等、
# Play Console で使っているトラック名に ANDROID_PLAY_TRACK を合わせる。
# 通常は android_release_build.sh 実行後に使い、
# fastlane supply とサービスアカウント JSON で配布します。
# 使用例: ./scripts/android/android_upload_internal_test.sh [AABのパス]
# クローズド例: ANDROID_PLAY_TRACK=alpha ./scripts/android/android_upload_internal_test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
APP_DIR="$ROOT_DIR/world_sudoku"
RELEASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../load_env.sh
source "$RELEASE_DIR/load_env.sh"

# 引数があればそのAABを使う。未指定ならandroid_release_build.shの出力先を使う。
AAB_PATH="${1:-$APP_DIR/build/app/outputs/bundle/release/app-release.aab}"
PACKAGE_NAME="${ANDROID_PACKAGE_NAME:-com.hakuchan.world_sudoku}"
JSON_KEY_PATH="${GOOGLE_PLAY_JSON_KEY_PATH:-/Users/hakuchan/Desktop/syumi/secrets/googlePlayConsoleService.json}"
TRACK="${ANDROID_PLAY_TRACK:-internal}"
# アプリがドラフトの場合は draft。一度リリース済みなら completed に変更可。
RELEASE_STATUS="${RELEASE_STATUS:-draft}"

if [[ -z "$JSON_KEY_PATH" ]]; then
  echo "ERROR: GOOGLE_PLAY_JSON_KEY_PATH を設定してください"
  echo "例: export GOOGLE_PLAY_JSON_KEY_PATH=/path/to/service-account.json"
  exit 1
fi

if [[ ! -f "$JSON_KEY_PATH" ]]; then
  echo "ERROR: サービスアカウントJSONが見つかりません: $JSON_KEY_PATH"
  exit 1
fi

if [[ ! -f "$AAB_PATH" ]]; then
  echo "ERROR: AABが見つかりません: $AAB_PATH"
  echo "先に ./scripts/android/android_release_build.sh を実行してください"
  exit 1
fi

if ! command -v fastlane >/dev/null 2>&1; then
  echo "ERROR: fastlane が見つかりません"
  echo "インストール例: brew install fastlane"
  exit 1
fi

echo "Uploading AAB to Google Play (track: $TRACK)..."
echo "package: $PACKAGE_NAME"
echo "track:   $TRACK"
echo "status:  $RELEASE_STATUS"
echo "aab:     $AAB_PATH"

fastlane supply \
  --aab "$AAB_PATH" \
  --package_name "$PACKAGE_NAME" \
  --track "$TRACK" \
  --release_status "$RELEASE_STATUS" \
  --json_key "$JSON_KEY_PATH" \
  --skip_upload_images true \
  --skip_upload_screenshots true \
  --skip_upload_metadata true

echo "Upload completed."
