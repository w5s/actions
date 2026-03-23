#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${CI_ASDF_TOOL:-}" ]]; then
  echo "setup-asdf-tool: input 'tool' is required (CI_ASDF_TOOL is empty)." >&2
  exit 1
fi

if [[ -z "${CI_ASDF_TOOL_VERSION:-}" ]]; then
  echo "setup-asdf-tool: input 'version' is required (CI_ASDF_TOOL_VERSION is empty)." >&2
  exit 1
fi

TOOL="$CI_ASDF_TOOL"
REQUESTED="$CI_ASDF_TOOL_VERSION"

normalize_tool() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]'
}

is_exact_semver() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

is_semver_selector() {
  [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]]
}

main() {
  local tool requested resolved

  tool="$(normalize_tool "$TOOL")"
  requested="$(echo "$REQUESTED" | tr -d '[:space:]')"

  if [[ -z "$tool" ]]; then
    echo "setup-asdf-tool: normalized 'tool' input is empty." >&2
    exit 1
  fi

  if [[ -z "$requested" ]]; then
    echo "setup-asdf-tool: normalized 'version' input is empty." >&2
    exit 1
  fi

  asdf plugin add "$tool" || true

  if is_exact_semver "$requested"; then
    resolved="$requested"
  elif is_semver_selector "$requested"; then
    resolved="$(asdf latest "$tool" "$requested" 2>/dev/null || true)"
    resolved="$(echo "$resolved" | tr -d '[:space:]')"
    if ! is_exact_semver "$resolved"; then
      echo "setup-asdf-tool: could not resolve $tool version selector '$requested'." >&2
      exit 1
    fi
  else
    echo "setup-asdf-tool: invalid version input '$requested'. Expected major-only (for example: 24), major.minor (for example: 24.14), or exact semver (for example: 24.14.0)." >&2
    exit 1
  fi

  echo "Resolved $tool version: $resolved"
  asdf set "$tool" "$resolved"
  echo "resolved-version=$resolved" >> "$GITHUB_OUTPUT"
}

main "$@"
