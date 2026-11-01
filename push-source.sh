#!/bin/bash
# Push the CV source to the public repo github.com/psychwangzihao/cv
# so that the "Source code for this CV" link on the PDF stays valid.
#
#   Usage:  bash cv/push-source.sh
#
# Uses the same token lookup as deploy.py (--token / $GITHUB_TOKEN /
# $GH_TOKEN / <workspace>/.deploy_token / /tmp/gh_token.env) and the same
# stdlib-only API helper, so no `gh` CLI is required.  All changed files go
# into a single commit.
set -e
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"

python3 - "$ROOT" <<'PY'
import base64, os, sys

ROOT = sys.argv[1]
sys.path.insert(0, ROOT)
import deploy                                   # noqa: E402  (shares token + api)

deploy.load_token()
REPO = "psychwangzihao/cv"
BRANCH = "main"
FILES = ["main.tex", "README.md", "build.sh", "push-source.sh"]

head = deploy.api("GET", f"repos/{REPO}/git/ref/heads/{BRANCH}")["object"]["sha"]
tree = deploy.api("GET", f"repos/{REPO}/git/trees/{head}?recursive=1")["tree"]
remote = {e["path"]: e["sha"] for e in tree if e["type"] == "blob"}

entries, changed = [], []
for name in FILES:
    if not os.path.isfile(name):
        print(f"  skip (missing): {name}")
        continue
    raw = open(name, "rb").read()
    blob = deploy.api("POST", f"repos/{REPO}/git/blobs",
                      {"content": base64.b64encode(raw).decode(),
                       "encoding": "base64"})
    if remote.get(name) == blob["sha"]:
        print(f"  unchanged: {name}")
        continue
    entries.append({"path": name, "mode": "100644", "type": "blob",
                    "sha": blob["sha"]})
    changed.append(name)

if not entries:
    print("\n✓ source already up to date -> https://github.com/psychwangzihao/cv")
    raise SystemExit(0)

new_tree = deploy.api("POST", f"repos/{REPO}/git/trees",
                      {"base_tree": head, "tree": entries})["sha"]
commit = deploy.api("POST", f"repos/{REPO}/git/commits",
                    {"message": "Update CV source: " + ", ".join(changed),
                     "tree": new_tree, "parents": [head]})["sha"]
deploy.api("PATCH", f"repos/{REPO}/git/refs/heads/{BRANCH}",
           {"sha": commit, "force": False})
print(f"  commit {commit[:7]}: {', '.join(changed)}")
print(f"\n✅ source synced -> https://github.com/psychwangzihao/cv")
PY
