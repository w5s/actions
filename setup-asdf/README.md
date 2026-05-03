# Setup asdf tools

Composite action to configure asdf, optionally resolve and set Node.js, Python, and Ruby versions, install system dependencies for missing plugins, then install tools.

## Usage

```yaml
- name: ⚙️ Setup asdf tools
  uses: w5s/actions/setup-asdf@main
  id: setup-asdf
  with:
    node-version: '24' # optional major
    # node-version: '24.14' # optional minor
    # node-version: '24.14.0' # optional exact version (used as-is)
    python-version: '3.13' # optional
    ruby-version: '3.4' # optional

- name: ℹ️ Resolved tool versions
  run: |
    echo "Node = ${{ steps.setup-asdf.outputs.resolved-node-version }}"
    echo "Python = ${{ steps.setup-asdf.outputs.resolved-python-version }}"
    echo "Ruby = ${{ steps.setup-asdf.outputs.resolved-ruby-version }}"
```

### Inputs

| Input            | Required | Description |
|------------------|----------|-------------|
| `node-version`   | No       | Node.js version to apply before `asdf install`. Accepts major-only (`24`), major.minor (`24.14`), or exact semver (`24.14.0`). Major/minor resolve to latest patch at runtime via `asdf latest nodejs <selector>`. Invalid formats (e.g. `24.x`) fail. Updates `.tool-versions` so the chosen version is used by subsequent steps. |
| `python-version` | No       | Python version to apply before `asdf install`. Accepts major-only (`3`), major.minor (`3.13`), or exact semver (`3.13.1`). Major/minor resolve to latest patch at runtime via `asdf latest python <selector>`. Invalid formats (e.g. `3.x`) fail. Updates `.tool-versions` so the chosen version is used by subsequent steps. |
| `ruby-version`   | No       | Ruby version to apply before `asdf install`. Accepts major-only (`3`), major.minor (`3.4`), or exact semver (`3.4.1`). Major/minor resolve to latest patch at runtime via `asdf latest ruby <selector>`. Invalid formats (e.g. `3.x`) fail. Updates `.tool-versions` so the chosen version is used by subsequent steps. |

### Outputs

| Output                    | Description |
|---------------------------|-------------|
| `resolved-node-version`   | Exact Node.js version resolved and installed when `node-version` is set. |
| `resolved-python-version` | Exact Python version resolved and installed when `python-version` is set. |
| `resolved-ruby-version`   | Exact Ruby version resolved and installed when `ruby-version` is set. |

## Requirements

- Job must run after `actions/checkout`.
- `.tool-versions` and/or at least one version input must be present to do meaningful work.
- On Debian/Ubuntu runners, Python and Ruby plugin installs automatically install their required `apt` packages the first time those plugins are added.
