#!/usr/bin/env bash

set -euo pipefail

PACKAGE_JSON_FILE="${PACKAGE_JSON_FILE:-package.json}"
TOOL_VERSIONS_FILE="${TOOL_VERSIONS_FILE:-.tool-versions}"

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  echo "$value"
}

normalize_package_manager() {
  local value
  value="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  value="$(trim "$value")"
  case "$value" in
    bun | pnpm | yarn | npm)
      echo "$value"
      ;;
    *)
      echo ""
      ;;
  esac
}

strip_integrity_suffix() {
  local version="$1"
  if [[ "$version" == *+* ]]; then
    version="${version%%+*}"
  fi
  echo "$version"
}

parse_package_manager_spec() {
  local spec="$1"
  local name version

  name="${spec%%@*}"
  if [[ "$spec" == "$name" ]]; then
    version=""
  else
    version="${spec#*@}"
    version="$(strip_integrity_suffix "$version")"
  fi

  name="$(normalize_package_manager "$name")"
  PARSED_PACKAGE_MANAGER="$name"
  PARSED_PACKAGE_MANAGER_VERSION="$version"
}

read_package_manager_from_package_json() {
  local spec

  if [[ ! -f "$PACKAGE_JSON_FILE" ]]; then
    return 0
  fi

  spec="$(jq -r '.packageManager // empty' "$PACKAGE_JSON_FILE")"
  if [[ -z "$spec" ]]; then
    return 0
  fi

  parse_package_manager_spec "$spec"
  PACKAGE_MANAGER="$PARSED_PACKAGE_MANAGER"
  PACKAGE_MANAGER_VERSION="$PARSED_PACKAGE_MANAGER_VERSION"
}

read_version_from_tool_versions() {
  local tool="$1"
  local plugin version normalized

  if [[ ! -f "$TOOL_VERSIONS_FILE" ]]; then
    return 0
  fi

  while read -r plugin version _; do
    [[ -z "${plugin:-}" || "${plugin:0:1}" == "#" ]] && continue
    normalized="$(normalize_package_manager "$plugin")"
    [[ -z "$normalized" ]] && continue
    if [[ "$normalized" == "$tool" ]]; then
      echo "$(trim "$version")"
      return 0
    fi
  done < "$TOOL_VERSIONS_FILE"

  echo ""
}

read_first_package_manager_from_tool_versions() {
  local plugin version normalized

  if [[ ! -f "$TOOL_VERSIONS_FILE" ]]; then
    echo ""
    return 0
  fi

  while read -r plugin version _; do
    [[ -z "${plugin:-}" || "${plugin:0:1}" == "#" ]] && continue
    normalized="$(normalize_package_manager "$plugin")"
    if [[ -n "$normalized" ]]; then
      PACKAGE_MANAGER="$normalized"
      PACKAGE_MANAGER_VERSION="$(trim "$version")"
      return 0
    fi
  done < "$TOOL_VERSIONS_FILE"

  echo ""
}

emit_outputs() {
  {
    echo "package_manager=$PACKAGE_MANAGER"
    echo "package_manager_version=$PACKAGE_MANAGER_VERSION"
  } >> "$GITHUB_OUTPUT"
}

main() {
  PACKAGE_MANAGER=""
  PACKAGE_MANAGER_VERSION=""

  if [[ ! -f "$PACKAGE_JSON_FILE" && ! -f "$TOOL_VERSIONS_FILE" ]]; then
    emit_outputs
    return 0
  fi

  read_package_manager_from_package_json

  if [[ -z "$PACKAGE_MANAGER" ]]; then
    read_first_package_manager_from_tool_versions
  fi

  if [[ -n "$PACKAGE_MANAGER" && -z "$PACKAGE_MANAGER_VERSION" ]]; then
    PACKAGE_MANAGER_VERSION="$(read_version_from_tool_versions "$PACKAGE_MANAGER")"
  fi

  emit_outputs
}

main "$@"
