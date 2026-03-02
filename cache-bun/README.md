# Cache bun

Sets up `actions/cache` for the bun cache directory (default: `~/.bun/install/cache`).

## Purpose

- Caches bun's package cache to speed up installs in subsequent runs.
- Exports `BUN_INSTALL_CACHE_DIR` via `GITHUB_ENV` so bun uses the same cache path in later steps.
- No-op when no `bun.lock` or `bun.lockb` file is found.
- Uses lockfile hash in the cache key for correctness.

Run after checkout; run before any bun install command.

## Usage

```yaml
- name: ⬇️ Checkout
  uses: actions/checkout@v4
- name: 📦 Cache bun
  uses: w5s/actions/cache-bun@main
  with:
    cache-path: .bun-cache # optional
```

## Inputs

- `cache-path` (optional): bun cache directory to store/restore. Defaults to `~/.bun/install/cache`.

## Requirements

- Use in projects that have `bun.lock` or `bun.lockb` (bun). Bun must be available (e.g. after `ci-setup`).
