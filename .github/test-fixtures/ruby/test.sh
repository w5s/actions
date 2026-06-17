#!/usr/bin/env bash
set -euo pipefail

expected_ruby_minor="$(awk '$1 == "ruby" { print $2 }' .tool-versions)"
actual_ruby_minor="$(ruby -e 'puts RUBY_VERSION.split(".")[0,2].join(".")')"
[[ "$actual_ruby_minor" == "$expected_ruby_minor" ]]
