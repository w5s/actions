# CI setup

Checkout is expected to be done before. This composite action configures the runner for Node/JS CI: tools setup from `.tool-versions`, package manager/cache setup, optional npm auth for GitHub Packages, Turbo cache, and Nx cache.

## Purpose

- **Turbo cache**: when `turbo.json` exists (or `turbo-cache` is `true`), configures caching for Turborepo.
- **Nx cache**: when `nx.json` exists (or `nx-cache` is `true`), computes base/head SHAs and restores/saves local `.nx/cache`.
- **Tools setup**: runs `w5s/actions/setup-tools` and installs selected tools using official setup actions (`actions/setup-node`, `actions/setup-python`, `ruby/setup-ruby`) with `.tool-versions` as source of truth.
- **Package manager cache**: when `node-cache` is not `false`, restores/saves npm cache (when `package-lock.json` exists), Yarn cache (when `yarn.lock` exists), pnpm store (when `pnpm-lock.yaml` exists), or Bun cache (when `bun.lockb` exists). Use `node-cache: 'true'` to force enable or `node-cache: 'false'` to disable.
- **Corepack**: enables Corepack when `package.json` declares `packageManager` (for Yarn/pnpm/Bun) via `w5s/actions/setup-corepack`.
- **GitHub Packages**: when `github-token` is set (defaults to `github.token`), configures npm for `//npm.pkg.github.com`.

## Usage

Use in a job after `actions/checkout`:

```yaml
- name: ⬇️ Checkout
  uses: actions/checkout@v6

- name: ⚙️ Setup CI
  uses: w5s/actions/setup@main
  id: setup
  with:
    node-version: '24' # optional major
    # node-version: '24.14' # optional minor
    # node-version: '24.14.0' # optional exact version (used as-is)
    github-token: ${{ secrets.GITHUB_TOKEN }} # optional, defaults to github.token (for GitHub Packages)
    node-cache: false # optional: force enable/disable package manager cache
    turbo-cache: false # optional: force enable/disable Turbo cache
    nx-cache: false # optional: force enable/disable Nx cache

- name: ℹ️ Resolved Node version
  run: echo "Node = ${{ steps.setup.outputs.resolved-node-version }}"
```

### Inputs

- `node-version` (optional): Node.js version override for tools setup. When unset, uses `nodejs` from `.tool-versions`.
- `github-token` (optional): GitHub token for npm auth (e.g. GitHub Packages). Defaults to `github.token`. When set, configures npm for `//npm.pkg.github.com`.
- `node-cache` (optional): Enable or disable package manager cache (npm, Yarn, pnpm, Bun) from GitHub Actions cache. `true` forces enable for all, `false` disables. When unset, cache runs when the matching lockfile exists (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, or `bun.lockb`).
- `turbo-cache` (optional): Enable or disable Turborepo cache from GitHub Actions cache. `true` forces enable, `false` disables. When unset, enables only when `turbo.json` exists.
- `nx-cache` (optional): Enable or disable Nx local cache from GitHub Actions cache. `true` forces enable, `false` disables. When unset, enables only when `nx.json` exists.

### Outputs

- `resolved-node-version`: Exact Node.js version resolved and installed when `node-version` is set.

## Version Strategy

- CI can keep major-only selectors (for example `24`, `22`, `20`) when using explicit `node-version`.
- When `node-version` is unset, `.tool-versions` remains the version source.
- Re-runs may pick newer patches when selectors are non-exact, depending on upstream setup action resolution.

## Requirements

- Job must run after `actions/checkout`.
- `package.json` is required for Corepack and package manager detection.
- When `node-cache` is unset, the presence of a lockfile (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, or `bun.lockb`) determines which package manager cache runs.
- `nx.json` is required for Nx SHA computation and cache steps (when `nx-cache` is not `false`).
- `turbo.json` is required for automatic Turbo cache setup when `turbo-cache` is unset.
