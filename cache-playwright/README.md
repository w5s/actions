# Cache Playwright

Caches Playwright browser binaries.

## Purpose

- Restores and saves the Playwright browser cache directory (default: `~/.cache/ms-playwright`).
- Exports `PLAYWRIGHT_BROWSERS_PATH` through `GITHUB_ENV` so later steps use the same browser location.

Run after checkout and before `playwright install` / `playwright install --with-deps`.

## Usage

```yaml
- name: ⬇️ Checkout
  uses: actions/checkout@v6

- name: 📦 Cache Playwright
  uses: w5s/actions/cache-playwright@main
  with:
    cache-path: .cache/ms-playwright # optional

- name: 🎭 Install Playwright browsers
  run: npx playwright install --with-deps
```

## Inputs

- `cache-enabled` (optional): enable or disable the Playwright browser cache. `true` forces enable, `false` disables. Unset: cache runs by default.
- `cache-path` (optional): Playwright browser cache directory. Defaults to `~/.cache/ms-playwright`.

## Requirements

- Use after `actions/checkout`.
- Install project dependencies before the later `playwright install` step so the local CLI is available.
