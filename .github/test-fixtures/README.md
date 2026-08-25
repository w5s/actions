# Action integration fixtures

This directory contains minimal sample projects used by workflow integration tests.
Each fixture provides a single `test.sh` entrypoint that runs setup/install checks.

- `npm/`: Node.js project for validating `setup-tools` + `install` with npm.
- `pnpm/`: Node.js project for validating `setup-tools` + `install` with pnpm (`packageManager` in `package.json`).
- `pnpm-tool-versions/`: Node.js project validating pnpm version from `.tool-versions` without `packageManager`.
- `yarn/`: Node.js project for validating `setup-tools` + `install` with yarn.
- `bun/`: Node.js project for validating `setup-tools` + `install` with bun.
- `node/`: Atomic Node.js fixture validating runtime setup from `.tool-versions`.
- `python/`: Atomic Python fixture validating runtime setup from `.tool-versions`.
- `ruby/`: Atomic Ruby fixture validating runtime setup from `.tool-versions`.
