#!/usr/bin/env bash
set -euo pipefail

# The fixture lives inside this repo's workspace. Install it as a standalone
# project so pnpm does not walk up to the root pnpm-lock.yaml.
pnpm install --ignore-workspace --frozen-lockfile

node -e "const isNumber = require('is-number'); if (!isNumber(42) || !isNumber('42') || isNumber('abc')) { process.exit(1); }"
