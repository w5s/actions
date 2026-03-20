#!/usr/bin/env bash
# Resolve task-manager (make | node | auto) and run make <task> or <pm> run <task>.
# To add a backend: add has_*(), register in resolve_auto() and run_resolved().

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

resolve_auto() {
  if has_makefile; then
    echo make
  elif has_package_json; then
    echo node
  else
    echo ""
  fi
}

normalize_manager_input() {
  local raw
  raw="$(echo "${CI_TASK_MANAGER:-auto}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  case "$raw" in
    make | node | auto) echo "$raw" ;;
    *)
      echo "ci-task: invalid task-manager '${CI_TASK_MANAGER:-}'. Use auto, make, or node." >&2
      exit 1
      ;;
  esac
}

resolve_task_manager() {
  local input resolved
  input="$(normalize_manager_input)"
  case "$input" in
    auto)
      resolved="$(resolve_auto)"
      if [[ -z "$resolved" ]]; then
        echo "ci-task: task-manager auto — no Makefile or package.json found; skipping."
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
    node)
      if ! has_package_json; then
        echo "ci-task: task-manager is node but package.json not found." >&2
        exit 1
      fi
      echo node
      ;;
  esac
}

run_make() {
  make "$TASK"
}

run_node() {
  local pm="${CI_NODE_PACKAGE_MANAGER:-npm}"
  "$pm" run "$TASK"
}

run_resolved() {
  case "$1" in
    make) run_make ;;
    node) run_node ;;
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
