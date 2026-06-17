#!/usr/bin/env bash
set -euo pipefail

expected_python_minor="$(awk '$1 == "python" { print $2 }' .tool-versions)"
actual_python_minor="$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")"
[[ "$actual_python_minor" == "$expected_python_minor" ]]
