#!/bin/bash
# Push the CV source to the public repo github.com/psychwangzihao/cv
# (the repo the "Source code for this CV" link points at).
#
#   Usage:  bash cv/push-source.sh
#
# This is a plain git push now: `cv/` is a real checkout of that repo, so the
# public history and the local history are the same one. The token is read from
# $GITHUB_TOKEN / $GH_TOKEN, or from <workspace>/.deploy_token.
set -e
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"

TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [ -z "$TOKEN" ] && [ -f "$ROOT/.deploy_token" ]; then
  TOKEN=$(grep -o 'ghp_[A-Za-z0-9]*' "$ROOT/.deploy_token" | head -1)
fi
if [ -z "$TOKEN" ]; then
  echo "❌ no token: set \$GITHUB_TOKEN or write one to $ROOT/.deploy_token" >&2
  exit 1
fi

git add -A
if git diff --cached --quiet; then
  echo "✓ source already up to date"
else
  FILES=$(git diff --cached --name-only | tr '\n' ' ')
  git commit -q -m "Update CV source: ${FILES% }"
  echo "  committed: ${FILES% }"
fi

AUTH=$(printf 'x-access-token:%s' "$TOKEN" | base64)
git -c http.extraheader="AUTHORIZATION: basic $AUTH" push -q origin main
echo "✅ source synced -> https://github.com/psychwangzihao/cv"
