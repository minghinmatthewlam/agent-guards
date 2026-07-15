#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA="$SCRIPT_DIR/../result.schema.json"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cat > "$TMP_DIR/flexible.json" <<'JSON'
{
  "status": "done",
  "result": "Implemented and verified the requested change.",
  "findings": [
    {"priority": "P1", "summary": "one"},
    {"priority": "P2", "summary": "two"},
    {"priority": "P2", "summary": "three"},
    {"priority": "P2", "summary": "four"}
  ],
  "evidence": ["test", {"command": "validate"}, ["smoke"]],
  "next": ["review", "integrate"],
  "risk": null,
  "worker_specific": {"attempts": 2}
}
JSON

cat > "$TMP_DIR/minimal.json" <<'JSON'
{"status":"blocked","result":"Credentials are unavailable."}
JSON

invalid_index=0
for invalid_case in \
  '{"result":"missing status"}' \
  '{"status":"done"}' \
  '{"status":"","result":"empty status"}' \
  '{"status":"done","result":""}' \
  '{"status":1,"result":"wrong status type"}' \
  '{"status":"done","result":false}' \
  '{"status":"done","result":"wrong findings type","findings":{}}' \
  '{"status":"done","result":"wrong finding item type","findings":["finding"]}' \
  '{"status":"done","result":"wrong evidence type","evidence":{}}'; do
  invalid_index=$((invalid_index + 1))
  printf '%s\n' "$invalid_case" > "$TMP_DIR/invalid-$invalid_index.json"
done

export SCHEMA TMP_DIR invalid_index
npx -y -p ajv-cli@5 -- bash -c '
  set -euo pipefail
  ajv validate --spec=draft7 -s "$SCHEMA" \
    -d "$TMP_DIR/flexible.json" -d "$TMP_DIR/minimal.json"

  set +e
  invalid_output="$(ajv validate --spec=draft7 -s "$SCHEMA" \
    -d "$TMP_DIR/invalid-*.json" 2>&1)"
  invalid_status=$?
  set -e
  rejected_count="$(printf "%s\n" "$invalid_output" | grep -c " invalid$")"
  if [ "$invalid_status" -eq 0 ] || [ "$rejected_count" -ne "$invalid_index" ]; then
    printf "%s\n" "$invalid_output" >&2
    echo "Expected all $invalid_index invalid fixtures to be rejected" >&2
    exit 1
  fi
'

echo "Pi worker result schema contract: OK"
