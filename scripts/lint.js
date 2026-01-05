#!/usr/bin/env node

const { execSync } = require('child_process');
const path = require('path');

// Get the current working directory
const cwd = process.cwd();

// Construct the Docker command with cross-platform path
const dockerCommand = `docker run --rm -v "${cwd}:/tmp/lint" oxsecurity/megalinter:v9`;

console.log('Running Mega Linter...');
console.log(`Command: ${dockerCommand}`);

try {
  execSync(dockerCommand, { stdio: 'inherit', shell: true });
  console.log('✅ Linting completed successfully!');
} catch (error) {
  console.error('❌ Linting failed');
  process.exit(error.status || 1);
}
