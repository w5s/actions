#!/usr/bin/env bash
# Resolve task-manager (make | npm | pnpm | yarn | bun | auto) and run make <task>
# or <pm> run <task>. To add a backend: add has_*(), register in
# detect_node_package_manager(), normalize_manager_input(), and run_resolved().

set -euo pipefail

if [[ -z "${CI_TASK_NAME:-}" ]]; then
  echo "ci-task: input 'task' is required (CI_TASK_NAME is empty)." >&2
  exit 1
fi

TASK="$CI_TASK_NAME"

has_makefile() {
  [[ -f Makefile || -f makefile || -f GNUmakefile ]]
}

has_package_json() {
  [[ -f package.json ]]
}

has_npm_lockfile() {
  [[ -f package-lock.json ]]
}

has_pnpm_lockfile() {
  [[ -f pnpm-lock.yaml ]]
}

has_yarn_lockfile() {
  [[ -f yarn.lock ]]
}

has_bun_lockfile() {
  [[ -f bun.lock || -f bun.lockb ]]
}

detect_node_package_manager() {
  local detected=()

  if has_yarn_lockfile; then
    detected+=(yarn)
  fi
  if has_pnpm_lockfile; then
    detected+=(pnpm)
  fi
  if has_bun_lockfile; then
    detected+=(bun)
  fi
  if has_npm_lockfile; then
    detected+=(npm)
  fi

  if [[ "${#detected[@]}" -gt 1 ]]; then
    echo "ci-task: multiple Node lockfiles found (${detected[*]}). Keep only one of yarn.lock, pnpm-lock.yaml, bun.lock/bun.lockb, or package-lock.json." >&2
    exit 1
  fi

  if [[ "${#detected[@]}" -eq 1 ]]; then
    echo "${detected[0]}"
  fi
}

resolve_auto() {
  if has_makefile; then
    echo make
  else
    detect_node_package_manager
  fi
}

normalize_manager_input() {
  local raw
  raw="$(echo "${CI_TASK_MANAGER:-auto}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  case "$raw" in
    make | npm | pnpm | yarn | bun | auto) echo "$raw" ;;
    *)
      echo "ci-task: invalid task-manager '${CI_TASK_MANAGER:-}'. Use auto, make, npm, pnpm, yarn, or bun." >&2
      exit 1
      ;;
  esac
}

validate_node_task_manager() {
  local pm="$1"

  if ! has_package_json; then
    echo "ci-task: task-manager is $pm but package.json not found." >&2
    exit 1
  fi
}

resolve_task_manager() {
  local input resolved
  input="$(normalize_manager_input)"
  case "$input" in
    auto)
      resolved="$(resolve_auto)"
      if [[ -z "$resolved" ]]; then
        echo "ci-task: task-manager auto — no Makefile or supported lockfile found; skipping."
        exit 0
      fi
      echo "$resolved"
      ;;
    make)
      if ! has_makefile; then
        echo "ci-task: task-manager is make but no Makefile (or makefile / GNUmakefile) found." >&2
        exit 1
      fi
      echo make
      ;;
    npm | pnpm | yarn | bun)
      validate_node_task_manager "$input"
      echo "$input"
      ;;
  esac
}

run_make() {
  make "$TASK"
}

run_node_package_manager() {
  local pm="$1"
  "$pm" run "$TASK"
}

run_resolved() {
  case "$1" in
    make) run_make ;;
    npm | pnpm | yarn | bun) run_node_package_manager "$1" ;;
    *)
      echo "ci-task: internal error — unknown task-manager '$1'." >&2
      exit 1
      ;;
  esac
}

main() {
  local resolved
  resolved="$(resolve_task_manager)"
  echo "ci-task: task '$TASK' (task-manager: $resolved)"
  run_resolved "$resolved"
}

main "$@"
