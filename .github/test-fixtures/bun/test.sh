#!/usr/bin/env bash
set -euo pipefail

expected_node="$(awk '$1 == "nodejs" { print $2 }' .tool-versions)"
actual_node="$(node -p 'process.versions.node')"
[[ "$actual_node" == "$expected_node" ]]

node -e "const isNumber = require('is-number'); if (!isNumber(42) || !isNumber('42') || isNumber('abc')) { process.exit(1); }"
