# CI task

Runs a **named** task via **Make** (`make <task>`) or **Node** (`<package-manager> run <task>`), or picks automatically.

## Purpose

- **`node`** — runs `${CI_NODE_PACKAGE_MANAGER:-npm} run <task>` when `package.json` exists.
- **`make`** — runs `make <task>` when a makefile exists (`Makefile`, `makefile`, or `GNUmakefile`).
- **`auto`** (default) — makefile first, else `package.json`; if neither exists, exits successfully with a skip message.

When both a makefile and `package.json` exist, **auto** chooses **make** first.

## Usage

```yaml
- # other setup steps ...

- name: 🔍 Validate
  uses: w5s/actions/task@main
  with:
    task: validate
```

## Inputs

| Input           | Required | Description |
|-----------------|----------|-------------|
| `task`          | yes      | Make target and/or `package.json` script name. |
| `task-manager` | no      | `auto` (default), `make`, or `node`. |
| `github-token`  | no       | Exported as `GITHUB_TOKEN` when set. |
| `node-options`  | no       | Sets `NODE_OPTIONS` for the step. |

## Requirements

- For **node**: `package.json` must define a script matching `task`.
- For **make**: the makefile must define a target matching `task`.

Logic lives in `main.sh` beside this file; extend backends there (`resolve_auto`, `run_resolved`).
