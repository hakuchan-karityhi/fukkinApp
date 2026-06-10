#!/bin/bash
# 後方互換用。本体は android_release_build.sh。
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/android_release_build.sh" "$@"
