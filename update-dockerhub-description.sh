#!/bin/bash -eu
# Pushes $1/README.md to Docker Hub as the full description for dzangolab/$1.
# Requires DOCKERHUB_USERNAME and DOCKERHUB_TOKEN env vars.

repo=$1

if [ ! -f "$repo/README.md" ]; then
  echo "No README.md in $repo, skipping description update"
  exit 0
fi

token=$(curl -s -H "Content-Type: application/json" \
  -X POST \
  -d "{\"username\": \"${DOCKERHUB_USERNAME}\", \"password\": \"${DOCKERHUB_TOKEN}\"}" \
  https://hub.docker.com/v2/users/login/ | python3 -c 'import sys,json;print(json.load(sys.stdin)["token"])')

python3 -c "
import json
with open('$repo/README.md') as f:
    readme = f.read()
print(json.dumps({'full_description': readme}))
" | curl -s -o /dev/null -w "%{http_code}\n" \
  -X PATCH \
  -H "Authorization: JWT ${token}" \
  -H "Content-Type: application/json" \
  -d @- \
  "https://hub.docker.com/v2/repositories/dzangolab/${repo}/"
