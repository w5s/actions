# Setup asdf tools

Composite action to configure asdf, optionally resolve and set a Node.js version, then install tools.

## Usage

```yaml
- name: ⚙️ Setup asdf tools
  uses: w5s/actions/setup-asdf@main
  id: setup-asdf
  with:
    node-version: '24' # optional major
    # node-version: '24.14' # optional minor
    # node-version: '24.14.0' # optional exact version (used as-is)

- name: ℹ️ Resolved Node version
  run: echo "Node = ${{ steps.setup-asdf.outputs.resolved-node-version }}"
```

### Inputs

| Input          | Required | Description |
|----------------|----------|-------------|
| `node-version` | No       | Node.js version to apply before `asdf install`. Accepts major-only (`24`), major.minor (`24.14`), or exact semver (`24.14.0`). Major/minor resolve to latest patch at runtime via `asdf latest nodejs <selector>`. Invalid formats (e.g. `24.x`) fail. Updates `.tool-versions` so the chosen version is used by subsequent steps. |

### Outputs

| Output                  | Description |
|-------------------------|-------------|
| `resolved-node-version` | Exact Node.js version resolved and installed when `node-version` is set. |

## Requirements

- Job must run after `actions/checkout`.
- `.tool-versions` and/or `node-version` must be present to do meaningful work.
