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
const CHROMIUM_DIR = path.resolve(ROOT_DIR, '..', 'src');

console.log('Syncing Base Core...\n');

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
    if (!options.ignoreErrors) {
      process.exit(1);
    }
  }
}

function syncGclient() {
  console.log('Syncing Chromium dependencies via gclient...\n');
  const parentDir = path.dirname(ROOT_DIR);
  exec('gclient sync', { cwd: parentDir });
  console.log('✓ gclient sync complete\n');
}

function applyPatches() {
  console.log('Applying Base Core patches...\n');
  exec('npm run apply_patches');
  console.log('✓ Patches applied\n');
}

function updateSubmodules() {
  console.log('Updating git submodules...\n');
  exec('git submodule update --init --recursive', { ignoreErrors: true });
  console.log('✓ Submodules updated\n');
}

function runHooks() {
  console.log('Running gclient hooks...\n');
  const parentDir = path.dirname(ROOT_DIR);
  exec('gclient runhooks', { cwd: parentDir });
  console.log('✓ Hooks complete\n');
}

function verifySetup() {
  console.log('Verifying setup...\n');

  const srcDir = path.resolve(ROOT_DIR, '..', 'src');
  if (!fs.existsSync(srcDir)) {
    console.error('✗ Chromium source directory not found');
    console.error('Please run: npm run init\n');
    process.exit(1);
  }

  console.log('✓ Setup verified\n');
}

function main() {
  console.log('Base Core Sync');
  console.log('==============\n');

  // Verify setup
  verifySetup();

  // Sync Chromium and dependencies
  syncGclient();

  // Update submodules
  updateSubmodules();

  // Apply patches
  applyPatches();

  // Run hooks
  runHooks();

  console.log('\n✓ Sync complete!\n');
  console.log('You can now build with: npm run build\n');
}

main();
