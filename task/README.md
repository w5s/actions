# CI task

Runs a **named** task via **Make** (`make <task>`) or a concrete Node package manager (`npm`, `pnpm`, `yarn`, or `bun`), or picks automatically.

## Purpose

- **`npm`** — runs `npm run <task>` when `package-lock.json` exists.
- **`pnpm`** — runs `pnpm run <task>` when `pnpm-lock.yaml` exists.
- **`yarn`** — runs `yarn run <task>` when `yarn.lock` exists.
- **`bun`** — runs `bun run <task>` when `bun.lock` or `bun.lockb` exists.
- **`make`** — runs `make <task>` when a makefile exists (`Makefile`, `makefile`, or `GNUmakefile`).
- **`auto`** (default) — makefile first, else detect the Node package manager from the lockfile; if neither exists, exits successfully with a skip message.

When both a makefile and `package.json` exist, **auto** chooses **make** first.
When multiple Node lockfiles exist, the action fails to avoid ambiguous package manager selection.

## Usage

```yaml
# - other setup steps ...

- name: 🔍 Validate
  uses: w5s/actions/task@main
  with:
    task: validate
```

## Inputs

| Input           | Required | Description |
|-----------------|----------|-------------|
| `task`          | yes      | Make target and/or `package.json` script name. |
| `task-manager` | no      | `auto` (default), `make`, `npm`, `pnpm`, `yarn`, or `bun`. |
| `github-token`  | no       | Exported as `GITHUB_TOKEN` when set. |
| `node-options`  | no       | Sets `NODE_OPTIONS` for the step. |

## Requirements

- For **npm / pnpm / yarn / bun**: `package.json` must define a script matching `task`, and the matching lockfile must be present.
- For **make**: the makefile must define a target matching `task`.

Logic lives in `main.sh` beside this file; extend backends there (`resolve_auto`, `run_resolved`).
