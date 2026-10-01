# Cache Node

Sets up `actions/cache` for bun, npm, pnpm, and yarn package manager caches.

## Purpose

- Caches package manager stores to speed up installs in subsequent runs.
- Exports the cache environment variables used by each package manager in later steps.
- No-ops per package manager when its project-root lockfile is not found, unless that cache is explicitly enabled.
- Uses project-root lockfile hashes in cache keys for correctness (nested lockfiles are ignored). The project root is `working-directory` (default: workspace root).
- For pnpm, when the store cache misses (or only a partial restore-keys hit), runs `pnpm store prune` after install and before the cache upload so unreferenced packages are not saved. npm, Yarn, and Bun have no equivalent selective prune.

Run after checkout and after the package managers are available; run before install commands.

## Usage

```yaml
- name: ⬇️ Checkout
  uses: actions/checkout@v4
- name: 📦 Cache Node package managers
  uses: w5s/actions/cache-node@main
  with:
    cache-key-prefix: my-project- # optional
    npm-cache-path: .npm-cache # optional
    pnpm-cache-path: .pnpm-store # optional
    yarn-cache-path: .yarn-cache # optional
    bun-cache-path: .bun-cache # optional
```

## Inputs

- `bun-cache-enabled` (optional): enable or disable bun cache. If unset, enabled when `bun.lock` or `bun.lockb` is found at the project root.
- `bun-cache-path` (optional): bun cache directory to store/restore. Defaults to `~/.bun/install/cache`.
- `npm-cache-enabled` (optional): enable or disable npm cache. If unset, enabled when `package-lock.json` is found at the project root.
- `npm-cache-path` (optional): npm cache directory to store/restore. Defaults to `~/.npm`.
- `pnpm-cache-enabled` (optional): enable or disable pnpm cache. If unset, enabled when `pnpm-lock.yaml` is found at the project root.
- `pnpm-cache-path` (optional): pnpm store directory to store/restore. Defaults to `~/.pnpm-store`.
- `pnpm-store-prune` (optional): when pnpm caching is active, prune unreferenced store packages after install and before cache upload. Defaults to enabled. Set to `"false"` to disable.
- `yarn-cache-enabled` (optional): enable or disable yarn cache. If unset, enabled when `yarn.lock` is found at the project root.
- `yarn-cache-path` (optional): yarn cache directory to store/restore. Defaults to `~/.yarn/cache`.
- `yarn-nm-mode` (optional): Yarn nm mode. Defaults to `"hardlinks-local"`.
- `cache-key-prefix` (optional): prefix prepended as-is to all cache keys and restore keys. Defaults to empty.
- `working-directory` (optional): Directory relative to `GITHUB_WORKSPACE` that contains the project files. Defaults to `.`.

## Requirements

- Use in projects that have at least one supported lockfile at the project root (`working-directory`): `bun.lock`, `bun.lockb`, `package-lock.json`, `pnpm-lock.yaml`, or `yarn.lock`. Auto-detection ignores nested lockfiles.
- Package managers must be available before forcing their cache on.
