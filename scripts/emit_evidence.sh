#!/usr/bin/env bash
set -euo pipefail

PLAN_JSON="plan.json"
CONFTEST_JSON="conftest.json"
OUTPUT="evidence.json"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat <<EOF > $OUTPUT
{
  "framework": "HIPAA Security Rule",
  "controls": [
    "164.312(a)(2)(iv)",
    "164.312(e)(1)",
    "164.308(a)(1)(ii)(D)"
  ],
  "artifacts": {
    "terraform_plan": "$PLAN_JSON",
    "policy_results": "$CONFTEST_JSON"
  },
  "timestamp": "$TIMESTAMP"
}
EOF

echo "Evidence written to $OUTPUT"
