#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${CI_ASDF_TOOL:-}" ]]; then
  echo "setup-asdf-tool: input 'tool' is required (CI_ASDF_TOOL is empty)." >&2
  exit 1
fi

TOOL="$CI_ASDF_TOOL"
REQUESTED="${CI_ASDF_TOOL_VERSION:-}"
PLUGIN_SOURCE="${CI_ASDF_PLUGIN_SOURCE:-}"
ACTION_MODE="${CI_ASDF_TOOL_ACTION_MODE:-install}"
TOOL_VERSIONS_FILE="${TOOL_VERSIONS_FILE:-.tool-versions}"

normalize_tool() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]'
}

is_exact_semver() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

is_semver_selector() {
  [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]]
}

trim_spaces() {
  echo "$1" | tr -d '[:space:]'
}

resolve_version_from_tool_versions() {
  local tool="$1"
  local version=""

  if [[ ! -f "$TOOL_VERSIONS_FILE" ]]; then
    echo "setup-asdf-tool: input 'version' is empty and $TOOL_VERSIONS_FILE was not found." >&2
    exit 1
  fi

  while read -r candidate version _; do
    [[ -z "${candidate:-}" || "${candidate:0:1}" == "#" ]] && continue
    if [[ "$(normalize_tool "$candidate")" == "$tool" ]]; then
      echo "$version"
      return 0
    fi
  done < "$TOOL_VERSIONS_FILE"

  echo "setup-asdf-tool: input 'version' is empty and tool '$tool' was not found in $TOOL_VERSIONS_FILE." >&2
  exit 1
}

plugin_cache_key() {
  local source="$1"
  local hash
  hash="$(printf '%s' "$source" | shasum -a 256 | awk '{print $1}')"
  echo "$hash"
}

resolve_requested_version() {
  local tool="$1"
  local requested="$2"
  local explicit_input="$3"
  local resolved=""

  if [[ -z "$requested" ]]; then
    requested="$(trim_spaces "$(resolve_version_from_tool_versions "$tool")")"
  fi

  if [[ -z "$requested" ]]; then
    echo "setup-asdf-tool: normalized 'version' value is empty." >&2
    exit 1
  fi

  if [[ "$explicit_input" != "true" ]]; then
    echo "$requested"
    return 0
  fi

  if is_exact_semver "$requested"; then
    resolved="$requested"
  elif is_semver_selector "$requested"; then
    resolved="$(asdf latest "$tool" "$requested" 2>/dev/null || true)"
    resolved="$(trim_spaces "$resolved")"
    if ! is_exact_semver "$resolved"; then
      echo "setup-asdf-tool: could not resolve $tool version selector '$requested'." >&2
      exit 1
    fi
  else
    echo "setup-asdf-tool: invalid explicit version input '$requested'. Expected major-only (for example: 24), major.minor (for example: 24.14), or exact semver (for example: 24.14.0)." >&2
    exit 1
  fi

  echo "$resolved"
}

install_and_set_tool() {
  local tool="$1"
  local resolved="$2"
  local plugin_source="$3"

  if [[ -n "$plugin_source" ]]; then
    asdf plugin add "$tool" "$plugin_source" || true
  else
    asdf plugin add "$tool" || true
  fi

  if [[ ! -d "${ASDF_DATA_DIR:-$HOME/.asdf}/installs/$tool/$resolved" ]]; then
    asdf install "$tool" "$resolved"
  fi
  asdf set "$tool" "$resolved"
}

main() {
  local tool requested resolved cache_key plugin_source

  tool="$(normalize_tool "$TOOL")"
  requested="$(trim_spaces "$REQUESTED")"
  plugin_source="$(trim_spaces "$PLUGIN_SOURCE")"

  if [[ -z "$tool" ]]; then
    echo "setup-asdf-tool: normalized 'tool' input is empty." >&2
    exit 1
  fi

  if [[ "$ACTION_MODE" != "resolve" && "$ACTION_MODE" != "install" ]]; then
    echo "setup-asdf-tool: unsupported action mode '$ACTION_MODE'." >&2
    exit 1
  fi

  if [[ -z "$plugin_source" ]]; then
    cache_key="$(plugin_cache_key "default")"
  else
    cache_key="$(plugin_cache_key "$plugin_source")"
  fi

  if [[ "$ACTION_MODE" == "resolve" ]]; then
    if [[ -n "$requested" ]]; then
      resolved="$(resolve_requested_version "$tool" "$requested" "true")"
    else
      resolved="$(resolve_requested_version "$tool" "$requested" "false")"
    fi
    {
      echo "resolved-version=$resolved"
      echo "plugin-cache-key=$cache_key"
    } >> "$GITHUB_OUTPUT"
    exit 0
  fi

  if [[ -n "${CI_ASDF_RESOLVED_VERSION:-}" ]]; then
    resolved="$(trim_spaces "${CI_ASDF_RESOLVED_VERSION:-}")"
  else
    if [[ -n "$requested" ]]; then
      resolved="$(resolve_requested_version "$tool" "$requested" "true")"
    else
      resolved="$(resolve_requested_version "$tool" "$requested" "false")"
    fi
  fi

  if [[ -z "$resolved" ]]; then
    echo "setup-asdf-tool: resolved version is empty." >&2
    exit 1
  fi

  if [[ -n "$requested" && ! is_exact_semver "$requested" && ! is_semver_selector "$requested" ]]; then
    echo "setup-asdf-tool: invalid explicit version input '$requested'. Expected major-only (for example: 24), major.minor (for example: 24.14), or exact semver (for example: 24.14.0)." >&2
    exit 1
  fi

  install_and_set_tool "$tool" "$resolved" "$plugin_source"
  echo "Resolved $tool version: $resolved"
  echo "resolved-version=$resolved" >> "$GITHUB_OUTPUT"
  echo "plugin-cache-key=$cache_key" >> "$GITHUB_OUTPUT"
}

main "$@"
