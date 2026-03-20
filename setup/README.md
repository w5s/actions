# CI setup

Checkout is expected to be done before. This composite action configures the runner for Node/JS CI: asdf tools, package manager/cache setup, optional npm auth for GitHub Packages, Turbo cache, and Nx cache.

## Purpose

- **Turbo cache**: when `turbo.json` exists (or `turbo-cache` is `true`), configures caching for Turborepo.
- **Nx cache**: when `nx.json` exists (or `nx-cache` is `true`), computes base/head SHAs and restores/saves local `.nx/cache`.
- **Tools via asdf**: runs `asdf-vm/actions/setup`, resolves `node-version` to an exact Node.js version, applies `asdf set nodejs <resolved>`, then runs `asdf install`.
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

| Input          | Required | Description |
|----------------|----------|-------------|
| `node-version` | No       | Node.js version to apply before `asdf install`. Accepts major-only (`24`), major.minor (`24.14`), or exact semver (`24.14.0`). Major/minor resolve to latest patch at runtime via `asdf latest nodejs <selector>`. Invalid formats (e.g. `24.x`) fail. Updates `.tool-versions` so the chosen version is used by subsequent steps. |
| `github-token` | No       | GitHub token for npm auth (e.g. GitHub Packages). Defaults to `github.token`. When set, configures npm for `//npm.pkg.github.com`. |
| `node-cache`   | No       | Enable/disable package manager cache (npm, Yarn, pnpm, Bun) from GitHub Actions cache. `true` forces enable for all, `false` disables. Unset: cache runs when the matching lockfile exists (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, or `bun.lockb`). |
| `turbo-cache`  | No       | Enable/disable Turborepo cache from GitHub Actions cache. `true` forces enable, `false` disables. Unset: enables only when `turbo.json` exists. |
| `nx-cache`     | No       | Enable/disable Nx local cache from GitHub Actions cache. `true` forces enable, `false` disables. Unset: enables only when `nx.json` exists. |

### Outputs

| Output                  | Description |
|-------------------------|-------------|
| `resolved-node-version` | Exact Node.js version resolved and installed when `node-version` is set. |

## Version Strategy

- CI can keep a major-only matrix (for example `24`, `22`, `20`).
- Each run resolves majors to the latest available patch at runtime.
- Re-runs may pick a newer patch and are expected to be non-strictly reproducible by design.

## Requirements

- Job must run after `actions/checkout`.
- `package.json` is required for Corepack and package manager detection.
- When `node-cache` is unset, the presence of a lockfile (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, or `bun.lockb`) determines which package manager cache runs.
- `nx.json` is required for Nx SHA computation and cache steps (when `nx-cache` is not `false`).
- `turbo.json` is required for automatic Turbo cache setup when `turbo-cache` is unset.
