#!/usr/bin/env bash

set -euo pipefail

APT_UPDATED=false

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

main() {
  local plugin="${1:-}"

  if [[ -z "$plugin" ]]; then
    echo 'Usage: setup-requirements.sh <asdf-plugin>'
    exit 1
  fi

  case "$plugin" in
    python)
      echo 'Installing Python build dependencies.'
      install_apt_packages make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev
      ;;
    ruby)
      echo 'Installing Ruby build dependencies.'
      install_apt_packages autoconf patch build-essential rustc libssl-dev \
        libyaml-dev zlib1g-dev libgmp-dev libreadline-dev libncurses5-dev \
        libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
      ;;
    *)
      echo "No additional system dependencies configured for plugin: $plugin"
      ;;
  esac
}

main "$@"
