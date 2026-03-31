# Cache yarn

Sets up `actions/cache` for the yarn cache directory (default: `~/.cache/yarn`).

## Purpose

- Caches yarn's global cache to speed up installs in subsequent runs.
- Exports `YARN_CACHE_FOLDER` (and `yarn_cache_folder`) via `GITHUB_ENV` so yarn uses the same cache path in later steps.
- No-op when no `yarn.lock` is found.
- Uses lockfile hash in the cache key for correctness.

Run after checkout; run before any yarn install command.

## Usage

```yaml
- name: ⬇️ Checkout
  uses: actions/checkout@v4
- name: 📦 Cache yarn
  uses: w5s/actions/cache-yarn@main
  with:
    cache-path: .yarn-cache # optional
```

## Inputs

- `cache-path` (optional): yarn cache directory to store/restore. Defaults to `~/.cache/yarn`.
- `nm-mode` (optional): Yarn nm mode. Default is `"hardlinks-local"`.

## Requirements

- Use in projects that have `yarn.lock` (yarn). Node/yarn must be available (e.g. after `ci-setup`).
