#!/usr/bin/env node

/**
 * Copyright (c) 2025 Base Core. All rights reserved.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at https://mozilla.org/MPL/2.0/.
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const ROOT_DIR = path.resolve(__dirname, '..');
const CHROMIUM_DIR = path.resolve(ROOT_DIR, '..', 'chromium');

console.log('Initializing Base Core development environment...\n');

function exec(command, options = {}) {
  console.log(`> ${command}`);
  try {
    execSync(command, {
      stdio: 'inherit',
      cwd: options.cwd || ROOT_DIR,
      ...options
    });
  } catch (error) {
    console.error(`Error executing: ${command}`);
    process.exit(1);
  }
}

function checkDepotTools() {
  console.log('Checking for depot_tools...');
  try {
    execSync('which gclient', { stdio: 'pipe' });
    console.log('✓ depot_tools found\n');
  } catch (error) {
    console.error('✗ depot_tools not found in PATH');
    console.error('\nPlease install depot_tools:');
    console.error('  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git');
    console.error('  export PATH=/path/to/depot_tools:$PATH\n');
    process.exit(1);
  }
}

function setupGclientConfig() {
  console.log('Setting up .gclient configuration...');

  const gclientConfig = `
solutions = [
  {
    "name": "src",
    "url": "https://chromium.googlesource.com/chromium/src.git",
    "managed": False,
    "custom_deps": {},
    "custom_vars": {},
  },
]
target_os = ["linux", "win", "mac"]
`;

  const parentDir = path.dirname(ROOT_DIR);
  const gclientPath = path.join(parentDir, '.gclient');

  fs.writeFileSync(gclientPath, gclientConfig);
  console.log(`✓ Created ${gclientPath}\n`);
}

function syncChromium() {
  console.log('Syncing Chromium source code...');
  console.log('This will download several gigabytes of data and may take a while...\n');

  const parentDir = path.dirname(ROOT_DIR);
  exec('gclient sync --no-history --shallow', { cwd: parentDir });
  console.log('\n✓ Chromium sync complete\n');
}

function setupSymlinks() {
  console.log('Setting up base-core symlinks...');

  const srcDir = path.resolve(ROOT_DIR, '..', 'src');
  const baseLink = path.join(srcDir, 'base');

  if (!fs.existsSync(srcDir)) {
    console.log('Creating src directory...');
    fs.mkdirSync(srcDir, { recursive: true });
  }

  if (fs.existsSync(baseLink)) {
    console.log('Removing existing base symlink...');
    fs.unlinkSync(baseLink);
  }

  console.log('Creating symlink: src/base -> base-core');
  fs.symlinkSync(ROOT_DIR, baseLink, 'dir');
  console.log('✓ Symlinks created\n');
}

function installDependencies() {
  console.log('Installing Chromium build dependencies...');
  console.log('You may need to run: ./build/install-build-deps.sh (Linux only)\n');
}

function main() {
  console.log('Base Core Initialization');
  console.log('========================\n');

  // Check prerequisites
  checkDepotTools();

  // Set up gclient configuration
  setupGclientConfig();

  // Sync Chromium source
  console.log('WARNING: This will download several GB of data.');
  console.log('Press Ctrl+C to cancel, or wait 5 seconds to continue...\n');

  // Give user time to cancel
  execSync('sleep 5');

  syncChromium();

  // Set up symlinks
  setupSymlinks();

  // Install dependencies
  installDependencies();

  console.log('\n✓ Initialization complete!\n');
  console.log('Next steps:');
  console.log('  1. Run: npm run sync');
  console.log('  2. Run: npm run build\n');
}

main();
