#!/bin/bash
# Rebuild the CV and install the PDF into the personal website.
#   Usage:  bash ~/cv/build.sh
# After it finishes, deploy with:  python3 ~/deploy.py pp
set -e
cd "$(dirname "$0")"

tectonic main.tex

DEST="$HOME/personal-homepage/assets/pdf/CV_WangZihao_ZJU.pdf"
cp main.pdf "$DEST"

echo
echo "✅ CV built  ->  $(pwd)/main.pdf"
echo "✅ installed ->  $DEST"
python3 - <<'PY'
from pypdf import PdfReader
import os
p = os.path.expanduser('~/personal-homepage/assets/pdf/CV_WangZihao_ZJU.pdf')
r = PdfReader(p)
print(f"   pages: {len(r.pages)}   size: {os.path.getsize(p)//1024} KB")
PY
echo
echo "Next:  python3 ~/deploy.py pp"
