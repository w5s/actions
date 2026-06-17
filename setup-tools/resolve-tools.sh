#!/usr/bin/env bash

set -euo pipefail

TOOL_VERSIONS_FILE="${TOOL_VERSIONS_FILE:-.tool-versions}"

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  echo "$value"
}

normalize_tool_name() {
  local value
  value="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  value="$(trim "$value")"
  case "$value" in
    node|nodejs)
      echo "node"
      ;;
    python)
      echo "python"
      ;;
    ruby)
      echo "ruby"
      ;;
    *)
      echo ""
      ;;
  esac
}

load_requested_tools() {
  local raw_list="$1"
  local list_name="$2"
  local token normalized

  if [[ -z "$raw_list" ]]; then
    return 0
  fi

  IFS=',' read -ra TOKENS <<< "$raw_list"
  for token in "${TOKENS[@]}"; do
    normalized="$(normalize_tool_name "$token")"
    if [[ -z "$normalized" ]]; then
      echo "setup-tools: unsupported tool in $list_name list: '$token'. Supported values: node, python, ruby." >&2
      exit 1
    fi
    case "$normalized" in
      node)
        REQUESTED_NODE=true
        ;;
      python)
        REQUESTED_PYTHON=true
        ;;
      ruby)
        REQUESTED_RUBY=true
        ;;
    esac
  done
}

load_tool_versions_file() {
  local plugin version normalized

  if [[ ! -f "$TOOL_VERSIONS_FILE" ]]; then
    return 0
  fi

  while read -r plugin version _; do
    [[ -z "${plugin:-}" || "${plugin:0:1}" == "#" ]] && continue
    normalized="$(normalize_tool_name "$plugin")"
    [[ -z "$normalized" ]] && continue
    case "$normalized" in
      node)
        TOOL_VERSION_NODE="$version"
        ;;
      python)
        TOOL_VERSION_PYTHON="$version"
        ;;
      ruby)
        TOOL_VERSION_RUBY="$version"
        ;;
    esac
  done < "$TOOL_VERSIONS_FILE"
}

is_selected() {
  local tool="$1"

  if [[ -n "$INCLUDE_RAW" ]]; then
    case "$tool" in
      node) [[ "$REQUESTED_NODE" == true ]] || return 1 ;;
      python) [[ "$REQUESTED_PYTHON" == true ]] || return 1 ;;
      ruby) [[ "$REQUESTED_RUBY" == true ]] || return 1 ;;
    esac
  fi

  case "$tool" in
    node) [[ "$EXCLUDED_NODE" == false ]] ;;
    python) [[ "$EXCLUDED_PYTHON" == false ]] ;;
    ruby) [[ "$EXCLUDED_RUBY" == false ]] ;;
  esac
}

emit_tool_outputs() {
  local tool="$1"
  local version="$2"
  local enabled="false"

  if is_selected "$tool" && [[ -n "$version" ]]; then
    enabled="true"
  fi

  {
    echo "$tool-enabled=$enabled"
    echo "$tool-version=$version"
  } >> "$GITHUB_OUTPUT"
}

main() {
  INCLUDE_RAW="${SETUP_TOOLS_INCLUDE:-}"
  EXCLUDE_RAW="${SETUP_TOOLS_EXCLUDE:-}"

  INPUT_NODE_VERSION="$(trim "${SETUP_TOOLS_NODE_VERSION:-}")"
  INPUT_PYTHON_VERSION="$(trim "${SETUP_TOOLS_PYTHON_VERSION:-}")"
  INPUT_RUBY_VERSION="$(trim "${SETUP_TOOLS_RUBY_VERSION:-}")"

  REQUESTED_NODE=false
  REQUESTED_PYTHON=false
  REQUESTED_RUBY=false
  EXCLUDED_NODE=false
  EXCLUDED_PYTHON=false
  EXCLUDED_RUBY=false

  TOOL_VERSION_NODE=""
  TOOL_VERSION_PYTHON=""
  TOOL_VERSION_RUBY=""

  load_requested_tools "$INCLUDE_RAW" "include"
  load_requested_tools "$EXCLUDE_RAW" "exclude"

  EXCLUDED_NODE="$REQUESTED_NODE"
  EXCLUDED_PYTHON="$REQUESTED_PYTHON"
  EXCLUDED_RUBY="$REQUESTED_RUBY"

  REQUESTED_NODE=false
  REQUESTED_PYTHON=false
  REQUESTED_RUBY=false
  load_requested_tools "$INCLUDE_RAW" "include"

  load_tool_versions_file

  NODE_VERSION="$INPUT_NODE_VERSION"
  PYTHON_VERSION="$INPUT_PYTHON_VERSION"
  RUBY_VERSION="$INPUT_RUBY_VERSION"

  [[ -z "$NODE_VERSION" ]] && NODE_VERSION="$TOOL_VERSION_NODE"
  [[ -z "$PYTHON_VERSION" ]] && PYTHON_VERSION="$TOOL_VERSION_PYTHON"
  [[ -z "$RUBY_VERSION" ]] && RUBY_VERSION="$TOOL_VERSION_RUBY"

  emit_tool_outputs "node" "$NODE_VERSION"
  emit_tool_outputs "python" "$PYTHON_VERSION"
  emit_tool_outputs "ruby" "$RUBY_VERSION"
}

main "$@"
