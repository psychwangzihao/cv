#!/bin/bash
# Push the CV source to the public repo github.com/psychwangzihao/cv
# so that the "Source code for this CV" link on the PDF stays valid.
#   Usage:  bash ~/cv/push-source.sh
set -e
cd "$(dirname "$0")"

# gh needs credentials: prefer the env, else the local token file
[ -z "$GH_TOKEN" ] && [ -f /tmp/gh_token.env ] && source /tmp/gh_token.env

python3 - <<'PY'
import base64, json, os, subprocess, sys
REPO = 'psychwangzihao/cv'
BRANCH = 'main'
FILES = ['main.tex', 'README.md', 'build.sh', 'push-source.sh']

def gh(method, ep, payload=None, allow_fail=False):
    cmd = ['gh', 'api', '--method', method, f'repos/{REPO}/{ep}']
    tmp = None
    if payload is not None:
        tmp = '/tmp/push_payload.json'
        open(tmp, 'w').write(json.dumps(payload))
        cmd += ['--input', tmp]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
    if tmp: os.remove(tmp)
    if r.returncode != 0:
        if allow_fail:
            return None
        print('API FAIL', ep, r.stderr[:300]); sys.exit(1)
    return json.loads(r.stdout) if r.stdout.strip() else {}

for f in FILES:
    if not os.path.exists(f):
        continue
    existing = gh('GET', f'contents/{f}?ref={BRANCH}', allow_fail=True)
    payload = {
        'message': f'Update {f}',
        'content': base64.b64encode(open(f, 'rb').read()).decode(),
        'branch': BRANCH,
    }
    if existing and 'sha' in existing:
        payload['sha'] = existing['sha']          # update
        action = 'updated'
    else:
        action = 'created'
    res = gh('PUT', f'contents/{f}', payload)
    print(f'  {action}: {f}  ({res.get("commit", {}).get("sha", "")[:7]})')

print('\n✅ source synced -> https://github.com/psychwangzihao/cv')
PY
