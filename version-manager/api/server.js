#!/usr/bin/env node

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const VERSION_FILE = path.join(__dirname, '../database/version.json');

function getVersionData() {
  try {
    const data = fs.readFileSync(VERSION_FILE, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error reading version file:', error);
    return null;
  }
}

function setCORSHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Content-Type', 'application/json');
}

const server = http.createServer((req, res) => {
  setCORSHeaders(res);

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host}`);
  const pathname = url.pathname;

  if (pathname === '/api/version' || pathname === '/api/version/current') {
    const versionData = getVersionData();
    if (!versionData) {
      res.writeHead(500);
      res.end(JSON.stringify({ error: 'Failed to load version data' }));
      return;
    }

    res.writeHead(200);
    res.end(JSON.stringify({
      version: versionData.current.version,
      codename: versionData.current.codename,
      release_date: versionData.current.release_date,
      chromium_base: versionData.current.chromium_base,
      build_number: versionData.current.build_number,
      channel: versionData.current.channel,
      download_url: `https://github.com/baseone/releases/download/v${versionData.current.version}/BaseOne-${versionData.current.version}-macos-arm64.dmg`
    }));
  }
  else if (pathname === '/api/version/check') {
    const currentVersion = url.searchParams.get('current');
    const versionData = getVersionData();

    if (!versionData) {
      res.writeHead(500);
      res.end(JSON.stringify({ error: 'Failed to load version data' }));
      return;
    }

    const latest = versionData.current.version;
    const updateAvailable = currentVersion !== latest;

    res.writeHead(200);
    res.end(JSON.stringify({
      current_version: currentVersion,
      latest_version: latest,
      update_available: updateAvailable,
      release_notes_url: `https://github.com/baseone/releases/tag/v${latest}`,
      download_url: updateAvailable ? `https://github.com/baseone/releases/download/v${latest}/BaseOne-${latest}-macos-arm64.dmg` : null
    }));
  }
  else if (pathname === '/api/version/history') {
    const versionData = getVersionData();
    if (!versionData) {
      res.writeHead(500);
      res.end(JSON.stringify({ error: 'Failed to load version data' }));
      return;
    }

    res.writeHead(200);
    res.end(JSON.stringify({
      history: versionData.history
    }));
  }
  else if (pathname === '/api/version/channels') {
    const versionData = getVersionData();
    if (!versionData) {
      res.writeHead(500);
      res.end(JSON.stringify({ error: 'Failed to load version data' }));
      return;
    }

    res.writeHead(200);
    res.end(JSON.stringify({
      channels: versionData.channels
    }));
  }
  else if (pathname === '/' || pathname === '/health') {
    res.writeHead(200);
    res.end(JSON.stringify({
      status: 'ok',
      service: 'BaseOne Version Manager',
      endpoints: [
        '/api/version/current',
        '/api/version/check?current=1.0.0',
        '/api/version/history',
        '/api/version/channels'
      ]
    }));
  }
  else {
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

server.listen(PORT, () => {
  console.log(`BaseOne Version Manager running on port ${PORT}`);
  console.log(`Endpoints:`);
  console.log(`  GET  /api/version/current`);
  console.log(`  GET  /api/version/check?current=1.0.0`);
  console.log(`  GET  /api/version/history`);
  console.log(`  GET  /api/version/channels`);
});
