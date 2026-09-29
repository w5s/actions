'use strict';

const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

if (process.env.STATE_prune !== 'true') {
  return;
}

// Skip when install never produced node_modules — pruning then empties a store
// restored from restore-keys and would upload a hollow cache under the new key.
const nodeModules = path.join(process.env.GITHUB_WORKSPACE || process.cwd(), 'node_modules');
if (!fs.existsSync(nodeModules)) {
  console.log('Skipping pnpm store prune: node_modules not found (install may have failed or been skipped).');
  return;
}

const result = spawnSync('pnpm', ['store', 'prune'], {
  encoding: 'utf8',
  stdio: 'inherit',
});

if (result.error) {
  throw result.error;
}
if (result.status !== 0) {
  process.exit(result.status ?? 1);
}
