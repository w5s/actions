#!/usr/bin/env bash
set -euo pipefail

node -e "const isNumber = require('is-number'); if (!isNumber(42) || !isNumber('42') || isNumber('abc')) { process.exit(1); }"
