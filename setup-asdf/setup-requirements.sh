#!/usr/bin/env bash

set -euo pipefail

APT_UPDATED=false

has_tool_requirement() {
  local tool="$1"
  local version="${2:-}"

  if [[ -n "$version" ]]; then
    return 0
  fi

  if [[ -f .tool-versions ]] && grep -Eq "^[[:space:]]*${tool}[[:space:]]+" .tool-versions; then
    return 0
  fi

  return 1
}

install_apt_packages() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo 'apt-get is not available. Skipping apt dependencies.'
    return 0
  fi

  if [[ "$APT_UPDATED" == false ]]; then
    sudo apt-get update
    APT_UPDATED=true
  fi

  sudo apt-get install -y "$@"
}

setup_python_requirements() {
  if ! has_tool_requirement python "${CI_ASDF_PYTHON_VERSION:-}"; then
    echo 'No Python requirement found. Skipping Python build dependencies.'
    return 0
  fi

  echo 'Python requirement found. Installing Python build dependencies.'
  install_apt_packages make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    libffi-dev liblzma-dev
}

main() {
  setup_python_requirements
}

main "$@"
