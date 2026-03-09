# CI setup

Checkout is expected to be done before. This composite action configures the runner for Node/JS CI: asdf tools, package manager/cache setup, optional npm auth for GitHub Packages, Turbo cache, and Nx cache.

## Purpose

- **Turbo cache**: when `turbo.json` exists, configures caching for Turborepo.
- **Nx cache**: when `nx.json` exists, computes base/head SHAs and restores/saves local `.nx/cache`.
- **Tools via asdf**: runs `asdf-vm/actions/setup`, resolves `node-version` to an exact Node.js version, applies `asdf set nodejs <resolved>`, then runs `asdf install`.
- **npm cache**: always restores/saves npm cache when `package.json` exists.
- **Corepack**: enables Corepack when `package.json` declares `packageManager` (for Yarn/pnpm).
- **Package manager cache**: caches Yarn cache folder and pnpm store between runs when the matching lockfile exists.
- **GitHub Packages**: when `github_token` is provided, configures npm for `//npm.pkg.github.com`.

## Usage

Use in a job after `actions/checkout`:

```yaml
- name: ⬇️ Checkout
  uses: actions/checkout@v6

- name: ⚙️ Setup CI
  uses: w5s/actions/setup@main
  id: setup
  with:
    # node-version: '24'                 # optional major (resolved at runtime to latest patch)
    # node-version: '24.14'              # optional major.minor (resolved at runtime to latest patch)
    # node-version: '24.14.0'            # optional exact version (used as-is)
    github-token: ${{ secrets.GITHUB_TOKEN }} # optional, for GitHub Packages
    # turbo-cache: 'true'   # optional override
    # nx-cache: 'false'     # optional override

- name: ℹ️ Resolved Node version
  run: echo "Node = ${{ steps.setup.outputs.resolved-node-version }}"
```

### Inputs

| Input          | Required | Description |
|----------------|----------|-------------|
| `node-version` | No       | Node.js version to apply before `asdf install`. Accepts major-only (`24`) or major.minor (`24.14`) which resolve to latest patch at runtime via `asdf latest nodejs <selector>`, or exact semver (`24.14.0`) used as-is. Invalid formats (for example `24.x`) fail. This updates local `.tool-versions` in the workspace so the chosen version is used by subsequent steps. |
| `github-token` | No       | GitHub token for npm auth (e.g. GitHub Packages). When set, configures npm for `//npm.pkg.github.com`. |
| `turbo-cache`  | No       | Enable/disable Turborepo cache from GitHub Actions cache. `true` forces enable, `false` disables, unset enables only when `turbo.json` exists. |
| `nx-cache`     | No       | Enable/disable Nx local cache from GitHub Actions cache. `true` forces enable, `false` disables, unset enables only when `nx.json` exists. |

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
- `package.json` is required for package-manager setup steps.
- `nx.json` is required for Nx setup/cache steps.
- `turbo.json` is required for automatic Turbo cache setup when `turbo-cache` is unset.
