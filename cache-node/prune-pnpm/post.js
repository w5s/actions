

import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

if (process.env.STATE_prune !== 'true') {
  process.exit(0);
}

// Skip when install never produced node_modules — pruning then empties a store
// restored from restore-keys and would upload a hollow cache under the new key.
const nodeModules = path.join(process.env.GITHUB_WORKSPACE || process.cwd(), 'node_modules');
if (!fs.existsSync(nodeModules)) {
  // eslint-disable-next-line no-console
  console.log('Skipping pnpm store prune: node_modules not found (install may have failed or been skipped).');
  process.exit(0);
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
