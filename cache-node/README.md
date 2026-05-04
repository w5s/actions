# Cache Node

Sets up `actions/cache` for bun, npm, pnpm, and yarn package manager caches.

## Purpose

- Caches package manager stores to speed up installs in subsequent runs.
- Exports the cache environment variables used by each package manager in later steps.
- No-ops per package manager when its lockfile is not found, unless that cache is explicitly enabled.
- Uses lockfile hashes in cache keys for correctness.

Run after checkout and after the package managers are available; run before install commands.

## Usage

```yaml
- name: ⬇️ Checkout
  uses: actions/checkout@v4
- name: 📦 Cache Node package managers
  uses: w5s/actions/cache-node@main
  with:
    npm-cache-path: .npm-cache # optional
    pnpm-cache-path: .pnpm-store # optional
    yarn-cache-path: .yarn-cache # optional
    bun-cache-path: .bun-cache # optional
```

## Inputs

- `bun-cache-enabled` (optional): enable or disable bun cache. If unset, enabled when `bun.lock` or `bun.lockb` is found.
- `bun-cache-path` (optional): bun cache directory to store/restore. Defaults to `~/.bun/install/cache`.
- `npm-cache-enabled` (optional): enable or disable npm cache. If unset, enabled when `package-lock.json` is found.
- `npm-cache-path` (optional): npm cache directory to store/restore. Defaults to `~/.npm`.
- `pnpm-cache-enabled` (optional): enable or disable pnpm cache. If unset, enabled when `pnpm-lock.yaml` is found.
- `pnpm-cache-path` (optional): pnpm store directory to store/restore. Defaults to `~/.pnpm-store`.
- `yarn-cache-enabled` (optional): enable or disable yarn cache. If unset, enabled when `yarn.lock` is found.
- `yarn-cache-path` (optional): yarn cache directory to store/restore. Defaults to `~/.yarn/cache`.
- `yarn-nm-mode` (optional): Yarn nm mode. Defaults to `"hardlinks-local"`.

## Requirements

- Use in projects that have at least one supported lockfile: `bun.lock`, `bun.lockb`, `package-lock.json`, `pnpm-lock.yaml`, or `yarn.lock`.
- Package managers must be available before forcing their cache on.
