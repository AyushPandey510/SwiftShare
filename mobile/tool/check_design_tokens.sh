#!/usr/bin/env bash
# Fails when screens/widgets hard-code colours instead of using design tokens.
# Usage (from mobile/):  bash tool/check_design_tokens.sh
set -euo pipefail
cd "$(dirname "$0")/.."

hits=$(grep -rnE "Color\(0x[0-9A-Fa-f]{8}\)" lib/screens lib/widgets lib/main.dart || true)
if [[ -n "$hits" ]]; then
  echo "❌ Hard-coded colours found. Use context.palette.* or AppColors.* instead:"
  echo "$hits"
  exit 1
fi
echo "✅ No hard-coded colours in screens/widgets."
