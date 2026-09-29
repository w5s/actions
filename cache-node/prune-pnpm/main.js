// Persist intent via GITHUB_STATE. Nested composite callers corrupt INPUT_* in post
// (actions/runner#2030); do not read inputs here or in post.js.
import fs from 'node:fs';

fs.appendFileSync(process.env.GITHUB_STATE, 'prune=true\n');
