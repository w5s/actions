# Setup tools

Composite action to setup Node.js, Python, and Ruby with official setup actions while using `.tool-versions` as the source of truth.

## Usage

```yaml
- name: ⚙️ Setup tools
  uses: w5s/actions/setup-tools@main
  id: setup-tools
  with:
    include: node,python
    # exclude: ruby
    # node-version: 24.14.0
    # python-version: 3.13.3
    # ruby-version: 3.4.2

- name: ℹ️ Resolved tool versions
  run: |
    echo "Node = ${{ steps.setup-tools.outputs.resolved-node-version }}"
    echo "Python = ${{ steps.setup-tools.outputs.resolved-python-version }}"
    echo "Ruby = ${{ steps.setup-tools.outputs.resolved-ruby-version }}"
```

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `include` | No | Comma-separated list of tools to include. Supported values: `node`, `python`, `ruby`. When unset, all supported tools are considered. |
| `exclude` | No | Comma-separated list of tools to exclude. Supported values: `node`, `python`, `ruby`. |
| `node-version` | No | Node.js version override. When unset, reads `nodejs` from `.tool-versions`. |
| `python-version` | No | Python version override. When unset, reads `python` from `.tool-versions`. |
| `ruby-version` | No | Ruby version override. When unset, reads `ruby` from `.tool-versions`. |

## Outputs

| Output | Description |
|--------|-------------|
| `resolved-node-version` | Exact Node.js version installed when Node setup runs. |
| `resolved-python-version` | Exact Python version installed when Python setup runs. |
| `resolved-ruby-version` | Exact Ruby version installed when Ruby setup runs. |

## Notes

- `.tool-versions` remains the default source for tool versions.
- `include` and `exclude` accept normalized names (`node`, `python`, `ruby`).
- `nodejs` in `.tool-versions` maps to `node` internally.
