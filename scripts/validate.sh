#!/usr/bin/env bash
# Single source of truth for meet-transcriber validation.
#
# Runs the exact checks the CI `validate` job runs, with zero dependencies
# (just `node` + `cmp`). Use this to validate locally — it does NOT depend on
# the GitHub-hosted runner, so it works even while Actions is unavailable.
#
#   bash scripts/validate.sh
#
# CI calls this same script, so local == CI by construction.
set -euo pipefail

cd "$(dirname "$0")/.."

cleanup() { rm -f ._mod_*.mjs; }
trap cleanup EXIT

echo "==> Extracting inline <script type=module> from index.html"
node -e '
  const fs = require("fs");
  const html = fs.readFileSync("index.html", "utf8");
  const re = /<script\b[^>]*type=["\x27]module["\x27][^>]*>([\s\S]*?)<\/script>/gi;
  let m, i = 0;
  while ((m = re.exec(html))) { fs.writeFileSync("._mod_" + i + ".mjs", m[1]); i++; }
  if (i === 0) { console.error("No inline <script type=module> found in index.html"); process.exit(1); }
  console.log("Extracted " + i + " inline module script(s)");
'

echo "==> node --check on each inline module"
for f in ._mod_*.mjs; do
  echo "    node --check $f"
  node --check "$f"
done

echo "==> Surge SPA-fallback invariant (200.html == index.html)"
if ! cmp -s index.html 200.html; then
  echo "ERROR: 200.html must be byte-identical to index.html (surge SPA fallback)" >&2
  exit 1
fi

echo "==> All checks passed."
