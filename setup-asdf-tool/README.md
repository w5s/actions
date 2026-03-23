# Setup asdf tool

This composite action resolves an asdf tool version selector to an exact version and applies it with `asdf set`.

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

- name: ℹ️ Resolved version
  run: echo "Node = ${{ steps.node.outputs.resolved-version }}"
```

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `tool` | Yes | asdf tool/plugin name, for example `nodejs`, `python`, or `ruby`. |
| `version` | Yes | Version selector to resolve. Accepts major-only (`24`), major.minor (`24.14`), or exact semver (`24.14.0`). |

## Outputs

| Output | Description |
|--------|-------------|
| `resolved-version` | Exact version resolved and applied with `asdf set`. |

## Notes

- The action runs `asdf plugin add <tool> || true` before resolving the version.
- Major-only and major.minor selectors are resolved with `asdf latest <tool> <selector>`.
- Exact semver values are used as-is.
