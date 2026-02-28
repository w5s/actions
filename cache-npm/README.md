# Cache npm

Sets up `actions/cache` for the npm cache directory (default: `~/.npm`).

## Purpose

- Caches npm's global cache to speed up `npm ci` in subsequent runs.
- Exports `NPM_CONFIG_CACHE` (and `npm_config_cache`) via `GITHUB_ENV` so npm uses the same cache path in later steps.
- No-op when no `package-lock.json` is found.
- Uses lockfile hash in the cache key for correctness.

Run after checkout; run before `ci-install` (or before any `npm ci`).

## Usage

```yaml
- name: ⬇️ Checkout
  uses: actions/checkout@v4
- name: 📦 Cache npm
  uses: w5s/actions/cache-npm@main
  with:
    cache-path: .npm-cache # optional
```

## Inputs

- `cache-path` (optional): npm cache directory to store/restore. Defaults to `~/.npm`.

## Requirements

- Use in projects that have `package-lock.json` (npm). Node/npm must be available (e.g. after `ci-setup`).
