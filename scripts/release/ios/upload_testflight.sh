#!/bin/bash
# 用途: 生成済み IPA を App Store Connect（TestFlight）へアップロードするスクリプト。
# App Store Connect API Key 認証を優先し、
# 未設定時は Apple ID + app-specific password でのアップロードにフォールバックします。
# 使用例: ./scripts/ios/upload_testflight.sh [IPAのパス]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
APP_DIR="$ROOT_DIR/world_sudoku"
RELEASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=../load_env.sh
source "$RELEASE_DIR/load_env.sh"

# 引数があればそのIPAを使う。未指定ならios_release_build.shの出力先を使う。
if [[ -n "${1:-}" ]]; then
  IPA_PATH="$1"
else
  # 最新のIPAを自動検出
  IPA_PATH=$(find "$APP_DIR/build/ios/ipa" -name "*.ipa" -type f 2>/dev/null | head -n 1)
fi

# App Store Connect API Key (推奨)
# https://appstoreconnect.apple.com/access/api でAPIキーを作成
API_KEY_ID="${APP_STORE_API_KEY_ID:-}"
API_ISSUER_ID="${APP_STORE_API_ISSUER_ID:-}"
API_KEY_PATH="${APP_STORE_API_KEY_PATH:-/Users/hakuchan/Desktop/syumi/secrets/AuthKey.p8}"

# Apple ID認証 (API Keyがない場合のフォールバック)
APPLE_ID="${APPLE_ID:-}"
APP_SPECIFIC_PASSWORD="${APP_SPECIFIC_PASSWORD:-}"

if [[ -z "$IPA_PATH" ]] || [[ ! -f "$IPA_PATH" ]]; then
  echo "ERROR: IPAが見つかりません: $IPA_PATH"
  echo "先に ./scripts/ios/ios_release_build.sh を実行してください"
  exit 1
fi

echo "Uploading IPA to TestFlight..."
echo "ipa: $IPA_PATH"

# API Key認証を優先
if [[ -n "$API_KEY_ID" ]] && [[ -n "$API_ISSUER_ID" ]] && [[ -f "$API_KEY_PATH" ]]; then
  echo "Using App Store Connect API Key authentication"
  
  # altoolが探すディレクトリにシンボリックリンクを自動作成
  ALTOOL_KEY_DIR="$HOME/.appstoreconnect/private_keys"
  AUTH_KEY_FILENAME="AuthKey_${API_KEY_ID}.p8"
  mkdir -p "$ALTOOL_KEY_DIR"
  if [[ ! -e "$ALTOOL_KEY_DIR/$AUTH_KEY_FILENAME" ]]; then
    ln -s "$API_KEY_PATH" "$ALTOOL_KEY_DIR/$AUTH_KEY_FILENAME"
    echo "Created symlink: $ALTOOL_KEY_DIR/$AUTH_KEY_FILENAME -> $API_KEY_PATH"
  fi
  
  xcrun altool --upload-app \
    --type ios \
    --file "$IPA_PATH" \
    --apiKey "$API_KEY_ID" \
    --apiIssuer "$API_ISSUER_ID"
elif [[ -n "$APPLE_ID" ]] && [[ -n "$APP_SPECIFIC_PASSWORD" ]]; then
  echo "Using Apple ID authentication"
  xcrun altool --upload-app \
    --type ios \
    --file "$IPA_PATH" \
    --username "$APPLE_ID" \
    --password "$APP_SPECIFIC_PASSWORD"
else
  echo ""
  echo "ERROR: 認証情報が設定されていません"
  echo ""
  echo "方法1: App Store Connect API Key (推奨)"
  echo "  export APP_STORE_API_KEY_ID=XXXXXXXXXX"
  echo "  export APP_STORE_API_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  echo "  export APP_STORE_API_KEY_PATH=/path/to/AuthKey_XXXXXXXXXX.p8"
  echo ""
  echo "方法2: Apple ID + App-specific password"
  echo "  export APPLE_ID=your@email.com"
  echo "  export APP_SPECIFIC_PASSWORD=xxxx-xxxx-xxxx-xxxx"
  echo "  (App-specific password: https://appleid.apple.com/account/manage)"
  echo ""
  exit 1
fi

echo ""
echo "Upload completed!"
echo "TestFlight でビルドを確認してください: https://appstoreconnect.apple.com"
