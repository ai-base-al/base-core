#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const VERSION_FILE = path.join(__dirname, '../database/version.json');

function loadVersionData() {
  const data = fs.readFileSync(VERSION_FILE, 'utf8');
  return JSON.parse(data);
}

function saveVersionData(data) {
  fs.writeFileSync(VERSION_FILE, JSON.stringify(data, null, 2));
}

function parseVersion(version) {
  const [major, minor, patch] = version.split('.').map(Number);
  return { major, minor, patch };
}

function incrementVersion(version, type) {
  const parts = parseVersion(version);

  switch (type) {
    case 'major':
      parts.major++;
      parts.minor = 0;
      parts.patch = 0;
      break;
    case 'minor':
      parts.minor++;
      parts.patch = 0;
      break;
    case 'patch':
      parts.patch++;
      break;
    default:
      throw new Error('Invalid version type. Use: major, minor, or patch');
  }

  return `${parts.major}.${parts.minor}.${parts.patch}`;
}

function bumpVersion(type, options = {}) {
  const data = loadVersionData();
  const oldVersion = data.current.version;
  const newVersion = incrementVersion(oldVersion, type);

  const currentDate = new Date().toISOString().split('T')[0];

  data.history.unshift({
    version: oldVersion,
    codename: data.current.codename,
    release_date: data.current.release_date,
    chromium_base: data.current.chromium_base,
    build_number: data.current.build_number,
    channel: data.current.channel,
    notes: options.notes || `Version ${oldVersion}`
  });

  data.current = {
    version: newVersion,
    codename: options.codename || data.current.codename,
    release_date: currentDate,
    chromium_base: options.chromium_base || data.current.chromium_base,
    build_number: data.current.build_number + 1,
    channel: options.channel || data.current.channel
  };

  data.channels[data.current.channel] = newVersion;

  saveVersionData(data);

  console.log(`Version bumped from ${oldVersion} to ${newVersion}`);
  console.log(`Build number: ${data.current.build_number}`);
  console.log(`Chromium base: ${data.current.chromium_base}`);
  console.log(`Release date: ${currentDate}`);

  return newVersion;
}

const args = process.argv.slice(2);
const type = args[0] || 'patch';
const codename = args.find(arg => arg.startsWith('--codename='))?.split('=')[1];
const chromium_base = args.find(arg => arg.startsWith('--chromium='))?.split('=')[1];
const notes = args.find(arg => arg.startsWith('--notes='))?.split('=')[1];
const channel = args.find(arg => arg.startsWith('--channel='))?.split('=')[1];

if (!['major', 'minor', 'patch'].includes(type)) {
  console.error('Usage: bump-version.js [major|minor|patch] [--codename=Name] [--chromium=142.0.0.0] [--notes=Release notes] [--channel=stable|beta|dev|canary]');
  process.exit(1);
}

bumpVersion(type, { codename, chromium_base, notes, channel });
