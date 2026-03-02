# Cache pnpm

Sets up `actions/cache` for the pnpm store directory (default: `~/.pnpm-store`).

## Purpose

- Caches pnpm's store to speed up installs in subsequent runs.
- Exports `PNPM_STORE_PATH` (and `npm_config_store_dir`) via `GITHUB_ENV` so pnpm uses the same store path in later steps.
- No-op when no `pnpm-lock.yaml` is found.
- Uses lockfile hash in the cache key for correctness.

Run after checkout; run before any pnpm install command.

## Usage

```yaml
- name: ⬇️ Checkout
  uses: actions/checkout@v4
- name: 📦 Cache pnpm
  uses: w5s/actions/cache-pnpm@main
  with:
    cache-path: .pnpm-store # optional
```

## Inputs

- `cache-path` (optional): pnpm store directory to store/restore. Defaults to `~/.pnpm-store`.

## Requirements

- Use in projects that have `pnpm-lock.yaml` (pnpm). Node/pnpm must be available (e.g. after `ci-setup`).
