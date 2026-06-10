#!/bin/bash
# 用途: Android リリース作業を直列で実行するラッパースクリプト。
# android_release_build.sh で AAB を作成し、
# android_upload_internal_test.sh で Play へアップロードします（既定トラックは internal）。
# クローズドテストへ出す例: ANDROID_PLAY_TRACK=alpha ./scripts/android/upload_android.sh
# 使用例（プロジェクトルートから）: ./scripts/android/upload_android.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "Android ビルド＆Play アップロード"
echo "=========================================="

echo ""
echo "[1/2] ビルド開始..."
"$SCRIPT_DIR/android_release_build.sh"

echo ""
echo "[2/2] Google Play へアップロード（ANDROID_PLAY_TRACK 未設定時は internal）..."
"$SCRIPT_DIR/android_upload_internal_test.sh"

echo ""
echo "=========================================="
echo "Android リリース完了!"
echo "=========================================="
