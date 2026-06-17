#!/usr/bin/env bash
set -euo pipefail

expected_node_major="$(awk '$1 == "nodejs" { print $2 }' .tool-versions)"
actual_node_major="$(node -p "process.versions.node.split('.')[0]")"
[[ "$actual_node_major" == "$expected_node_major" ]]
