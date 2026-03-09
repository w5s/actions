# CI setup

Checkout is expected to be done before. This composite action configures the runner for Node/JS CI: asdf tools, package manager/cache setup, optional npm auth for GitHub Packages, Turbo cache, and Nx cache.

## Purpose

- **Turbo cache**: when `turbo.json` exists, configures caching for Turborepo.
- **Nx cache**: when `nx.json` exists, computes base/head SHAs and restores/saves local `.nx/cache`.
- **Tools via asdf**: runs `asdf-vm/actions/setup`, optionally applies `asdf set nodejs <version>`, then runs `asdf install`.
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
  with:
    # node-version: '20.19.0'            # optional, applied via `asdf set nodejs ...`
    github-token: ${{ secrets.GITHUB_TOKEN }}  # optional, for GitHub Packages
    # turbo-cache: 'true'   # optional override
    # nx-cache: 'false'     # optional override
```

### Inputs

| Input          | Required | Description |
|----------------|----------|-------------|
| `node-version` | No       | Node.js version set with `asdf set nodejs <version>` before `asdf install`. This updates local `.tool-versions` in the workspace so the chosen version is used by subsequent steps. |
| `github-token` | No       | GitHub token for npm auth (e.g. GitHub Packages). When set, configures npm for `//npm.pkg.github.com`. |
| `turbo-cache`  | No       | Enable/disable Turborepo cache from GitHub Actions cache. `true` forces enable, `false` disables, unset enables only when `turbo.json` exists. |
| `nx-cache`     | No       | Enable/disable Nx local cache from GitHub Actions cache. `true` forces enable, `false` disables, unset enables only when `nx.json` exists. |

## Requirements

- Job must run after `actions/checkout`.
- `package.json` is required for package-manager setup steps.
- `nx.json` is required for Nx setup/cache steps.
- `turbo.json` is required for automatic Turbo cache setup when `turbo-cache` is unset.
