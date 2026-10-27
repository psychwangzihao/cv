#!/bin/bash
# Rebuild the CV and install the PDF into the personal website.
#
#   Usage:  bash cv/build.sh            (from anywhere)
#   Then:   python3 deploy.py pp        (to publish)
#
# Works whether the workspace lives at ~/cv or ~/Documents/GitHub/cv: every
# path is derived from this script's location.
set -e
cd "$(dirname "$0")"
CV="$(pwd)"
ROOT="$(cd .. && pwd)"                    # the GitHub workspace folder
SITE="$ROOT/personal-homepage"
DEST="$SITE/assets/pdf/CV_WangZihao_ZJU.pdf"

# ── locate a LaTeX engine ──────────────────────────────────────────────
TECTONIC="$(command -v tectonic || true)"
[ -z "$TECTONIC" ] && [ -x "$ROOT/.tools/tectonic" ] && TECTONIC="$ROOT/.tools/tectonic"
if [ -z "$TECTONIC" ]; then
  cat >&2 <<'EOF'
❌  No LaTeX engine found.
    Install Tectonic (no 5 GB MacTeX needed):
        brew install tectonic
    or drop the single binary at <workspace>/.tools/tectonic
    (https://github.com/tectonic-typesetting/tectonic/releases)
    Overleaf also works: upload main.tex, set the compiler to XeLaTeX.
EOF
  exit 1
fi

# Tectonic caches downloaded packages under ~/Library/Caches. If $HOME is not
# actually writable (sandboxed shells), fall back to a cache in the workspace.
CACHE_PROBE="$HOME/Library/Caches/.cv-write-test.$$"
if ! (mkdir -p "$HOME/Library/Caches" 2>/dev/null && : > "$CACHE_PROBE" 2>/dev/null); then
  export HOME="$ROOT/.tools/home"
  mkdir -p "$HOME"
else
  rm -f "$CACHE_PROBE"
fi

echo "▶ $TECTONIC -X compile main.tex"
"$TECTONIC" -X compile main.tex

mkdir -p "$(dirname "$DEST")"
cp main.pdf "$DEST"

echo
echo "✅ CV built    -> $CV/main.pdf"
echo "✅ installed   -> $DEST"

# page count / size, if pypdf happens to be around
PY="$ROOT/.tools/venv/bin/python"
[ -x "$PY" ] || PY="$(command -v python3 || true)"
if [ -n "$PY" ]; then
  "$PY" - "$DEST" <<'PY' || true
import os, sys
path = sys.argv[1]
kb = os.path.getsize(path) // 1024
try:
    from pypdf import PdfReader
    print(f"   pages: {len(PdfReader(path).pages)}   size: {kb} KB")
except ImportError:
    print(f"   size: {kb} KB  (pip install pypdf for a page count)")
PY
fi

echo
echo "Next:  python3 deploy.py pp"
