# Setup Node package manager

Installs the Node.js package manager declared in the project, using official setup actions instead of Corepack.

## Purpose

- Detects the package manager from `package.json` (`packageManager`), then `.tool-versions`.
- Installs the selected manager with ecosystem-maintained tooling:
  - **bun** — [`oven-sh/setup-bun`](https://github.com/oven-sh/setup-bun)
  - **pnpm** — [`pnpm/action-setup`](https://github.com/pnpm/action-setup)
  - **yarn** — `npm install -g @yarnpkg/cli-dist@<version>` (Yarn 2+; Yarn 1.x uses the `yarn` package)
  - **npm** — no extra install (bundled with Node.js)
- No-op when neither `package.json` nor `.tool-versions` exists.

Run after checkout and Node.js setup; run before installing dependencies.

## Version resolution

1. **`package.json`** — read `packageManager` (`name` or `name@version`). Integrity suffixes (`+sha224.…`) are stripped.
2. **`.tool-versions`** — read `bun`, `pnpm`, `yarn`, or `npm` entries (plain text; no asdf/mise runtime).

When the manager name is known but the version is missing, the version is read from `.tool-versions`. Lockfiles are not used: they do not pin the package manager version.

## Usage

```yaml
- name: ⬇️ Checkout
  uses: actions/checkout@v6

- name: ⚙️ Setup Node.js
  uses: actions/setup-node@v7
  with:
    node-version: 24

- name: ⚙️ Setup Node package manager
  uses: w5s/actions/setup-node-package-manager@main
  id: package-manager

- name: ℹ️ Package manager
  run: echo "${{ steps.package-manager.outputs.package_manager }}@${{ steps.package-manager.outputs.package_manager_version }}"
```

## Example `.tool-versions`

```text
nodejs 24.19.0
pnpm 11.22.0
```

## Requirements

- Node.js must be available for Yarn and npm workflows.
- Provide `packageManager` in `package.json` and/or a package manager entry in `.tool-versions` for deterministic versions.
