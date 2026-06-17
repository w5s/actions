# Action integration fixtures

This directory contains minimal sample projects used by workflow integration tests.
Each fixture includes a `test.sh` script that verifies its post-install behavior.

- `npm/`: Node.js project for validating `setup-tools` + `install` with npm.
- `pnpm/`: Node.js project for validating `setup-tools` + `install` with pnpm.
- `yarn/`: Node.js project for validating `setup-tools` + `install` with yarn.
- `bun/`: Node.js project for validating `setup-tools` + `install` with bun.
