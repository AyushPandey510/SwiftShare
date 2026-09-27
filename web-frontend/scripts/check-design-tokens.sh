#!/usr/bin/env bash
# Fails if app code uses raw colours instead of design tokens.
# Usage (from web-frontend/):  npm run check:tokens
set -euo pipefail
cd "$(dirname "$0")/.."

pattern='\b(bg|text|border|ring|fill|stroke|from|to|via|divide|outline|placeholder)-((white|black|gray|slate|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)(-[0-9]{2,3})?|\[#[0-9A-Fa-f]{3,8}\])'
hits=$(grep -rnE "$pattern" src --include='*.tsx' --include='*.ts' | grep -v 'src/components/ui/' || true)

if [[ -n "$hits" ]]; then
  echo "❌ Raw colours found. Use token classes (bg-card, text-muted-foreground, text-success...) instead:"
  echo "$hits"
  exit 1
fi
echo "✅ No raw colours in app code."
