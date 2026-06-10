#!/bin/bash
# 用途: iOS と Android の「ビルド→アップロード」を一括実行するスクリプト。
# iOS は TestFlight、Android は Google Play 内部テスト向け。
# 同一 Flutter プロジェクト（world_sudoku）のビルドキャッシュ競合を避けるため、
# プラットフォーム間は直列実行します（iOS → Android）。
# 使用例: ./scripts/release_all.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "iOS & Android ビルド＆アップロード開始（直列: iOS → Android）"
echo "=========================================="

IOS_EXIT=0
ANDROID_EXIT=0

echo ""
echo "[iOS] ビルド＆TestFlight アップロード..."
"$SCRIPT_DIR/ios/upload_ios.sh" || IOS_EXIT=$?

if [ "$IOS_EXIT" -eq 0 ]; then
  echo ""
  echo "[iOS] 完了!"
fi

echo ""
echo "[Android] ビルド＆Play アップロード..."
"$SCRIPT_DIR/android/upload_android.sh" || ANDROID_EXIT=$?

if [ "$ANDROID_EXIT" -eq 0 ]; then
  echo ""
  echo "[Android] 完了!"
fi

echo ""
echo "=========================================="
echo "結果:"
if [ $IOS_EXIT -eq 0 ]; then
  echo "  iOS:     ✓ 成功"
else
  echo "  iOS:     ✗ 失敗 (exit code: $IOS_EXIT)"
fi

if [ $ANDROID_EXIT -eq 0 ]; then
  echo "  Android: ✓ 成功"
else
  echo "  Android: ✗ 失敗 (exit code: $ANDROID_EXIT)"
fi
echo "=========================================="

if [ $IOS_EXIT -ne 0 ] || [ $ANDROID_EXIT -ne 0 ]; then
  exit 1
fi
