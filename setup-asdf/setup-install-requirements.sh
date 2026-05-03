#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_VERSIONS_FILE="${TOOL_VERSIONS_FILE:-.tool-versions}"
ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"

append_plugin() {
  local plugin="$1"

  if [[ -z "$plugin" ]]; then
    return 0
  fi

  if [[ " ${PLUGINS[*]:-} " == *" $plugin "* ]]; then
    return 0
  fi

  PLUGINS+=("$plugin")
}

collect_plugins() {
  local plugin _

  if [[ -f "$TOOL_VERSIONS_FILE" ]]; then
    while read -r plugin _; do
      [[ -z "$plugin" || "$plugin" == \#* ]] && continue
      append_plugin "$plugin"
    done <"$TOOL_VERSIONS_FILE"
  fi

  if [[ -n "${CI_ASDF_NODE_VERSION:-}" ]]; then
    append_plugin "nodejs"
  fi

  if [[ -n "${CI_ASDF_PYTHON_VERSION:-}" ]]; then
    append_plugin "python"
  fi

  if [[ -n "${CI_ASDF_RUBY_VERSION:-}" ]]; then
    append_plugin "ruby"
  fi
}

plugin_is_installed() {
  local plugin="$1"
  [[ -d "$ASDF_DATA_DIR/plugins/$plugin" ]]
}

main() {
  local plugin

  collect_plugins

  for plugin in "${PLUGINS[@]:-}"; do
    if plugin_is_installed "$plugin"; then
      echo "asdf plugin already installed: $plugin"
      continue
    fi

    echo "asdf plugin missing, installing system requirements: $plugin"
    bash "$SCRIPT_DIR/setup-requirements.sh" "$plugin"
  done
}

declare -a PLUGINS=()

main "$@"
