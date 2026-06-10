#!/bin/bash
# このコマンドでIPA作成とリリースを行う
# 用途: iOS リリース作業を直列で実行するラッパースクリプト。
# ios_upload_build.sh で IPA を作成し、
# upload_testflight.sh で TestFlight へアップロードします。
# 使用例（プロジェクトルートから）: ./scripts/ios/upload_ios.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "iOS ビルド＆TestFlightアップロード"
echo "=========================================="

echo ""
echo "[1/2] ビルド開始..."
"$SCRIPT_DIR/ios_upload_build.sh"

echo ""
echo "[2/2] TestFlightへアップロード..."
"$SCRIPT_DIR/upload_testflight.sh"

echo ""
echo "=========================================="
echo "iOS リリース完了!"
echo "=========================================="
