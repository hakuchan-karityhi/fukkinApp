#!/bin/bash
# scripts/release/.env を読み込む共通ローダー
# 各リリーススクリプトから source して使用する

_RELEASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ENV_FILE="$_RELEASE_DIR/.env"

if [[ -f "$_ENV_FILE" ]]; then
  echo "Loading environment from $_ENV_FILE"
  set -a
  # shellcheck source=/dev/null
  source "$_ENV_FILE"
  set +a
fi

unset _RELEASE_DIR _ENV_FILE
