# Setup Node package manager

Enables Corepack based on the `packageManager` field in `package.json`, and reshims `asdf` if present.

## Purpose

- Reads `package.json` and enables Corepack when `packageManager` is set (for Yarn, pnpm, or Bun).
- Installs Corepack if it is missing.
- Runs `asdf reshim nodejs` when `asdf` is available so new shims are ready for later steps.
- No-op when `package.json` is missing or `packageManager` is empty.

Run after checkout; run before installing dependencies.

## Usage

```yaml
- name: ⬇️ Checkout
  uses: actions/checkout@v6

- name: ⚙️ Setup Node package manager
  uses: w5s/actions/setup-corepack@main
```

## Requirements

- `package.json` must exist and include `packageManager` to enable Corepack.
- Node/npm must be available (for installing Corepack if missing).
