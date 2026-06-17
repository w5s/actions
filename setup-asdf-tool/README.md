# Setup asdf tool

This composite action resolves or reads an asdf tool version and applies it with `asdf set`.

## Usage

```yaml
- name: ⚙️ Setup asdf
  uses: asdf-vm/actions/setup@v4

- name: ⚙️ Set Node.js version
  id: node
  uses: w5s/actions/setup-asdf-tool@main
  with:
    tool: nodejs
    version: '24'
    # plugin: https://github.com/asdf-vm/asdf-nodejs.git # optional

- name: ℹ️ Resolved version
  run: echo "Node = ${{ steps.node.outputs.resolved-version }}"
```

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `tool` | Yes | asdf tool/plugin name, for example `nodejs`, `python`, or `ruby`. |
| `version` | No | Optional version selector. Accepts major-only (`24`), major.minor (`24.14`), or exact semver (`24.14.0`). When omitted, the action reads the tool value from `.tool-versions`. |
| `plugin` | No | Optional plugin source used as `asdf plugin add <tool> <plugin>` (plugin name or repository URL). |

## Outputs

| Output | Description |
|--------|-------------|
| `resolved-version` | Exact version resolved and applied with `asdf set`. |

## Notes

- The action restores cache per tool plugin directory: `${ASDF_DATA_DIR}/plugins/<tool>`.
- The action restores cache per tool install directory: `${ASDF_DATA_DIR}/installs/<tool>/<resolved-version>`.
- Explicit `version` selectors keep previous behavior:
  - major-only and major.minor values resolve through `asdf latest <tool> <selector>`
  - exact semver values are used as-is.
- When `version` is omitted, the value from `.tool-versions` is used as-is (default asdf behavior).
