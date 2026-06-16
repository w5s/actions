# Action integration fixtures

This directory contains minimal sample projects used by workflow integration tests.
Each fixture includes a `test.sh` script that verifies its post-install behavior.

- `pnpm/`: Node.js project for validating `setup` + `install` with pnpm.
- `yarn/`: Node.js project for validating `setup` + `install` with yarn.
- `bun/`: Node.js project for validating `setup` + `install` with bun.
- `pip/`: Python project for validating pip installs in fixture verification.
- `uv/`: Python project for validating `setup` + `install` with uv.
