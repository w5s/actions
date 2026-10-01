// Persist intent via GITHUB_STATE. Nested composite callers corrupt INPUT_* in post
// (actions/runner#2030); do not read inputs here or in post.js.
import fs from 'node:fs';
import path from 'node:path';

const workingDirectory = process.env.PRUNE_WORKING_DIRECTORY || '.';
const workspaceRoot = process.env.GITHUB_WORKSPACE || process.cwd();
const projectDirectory = path.isAbsolute(workingDirectory)
  ? workingDirectory
  : path.join(workspaceRoot, workingDirectory);

fs.appendFileSync(process.env.GITHUB_STATE, 'prune=true\n');
fs.appendFileSync(process.env.GITHUB_STATE, `workingDirectory=${projectDirectory}\n`);
