#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const assert = require('assert');

// Resolve the settings file path in the user's Library directory
const filePath = path.join(process.env.HOME, 'Library', 'Application Support', 'Cursor', 'User', 'settings.json');

let raw;
try {
  raw = fs.readFileSync(filePath, 'utf8');
} catch (err) {
  console.error(`Failed to read settings.json at ${filePath}:`, err.message);
  process.exit(1);
}

let config;
try {
  config = JSON.parse(raw);
} catch (err) {
  console.error('settings.json contains invalid JSON:', err.message);
  process.exit(1);
}

// Validate required Cursor AI settings
try {
  assert.strictEqual(config['cursor.ai.model'], 'o4-mini', 'cursor.ai.model should be o4-mini');
  assert.strictEqual(config['cursor.ai.maxTokens'], 4096, 'cursor.ai.maxTokens should be 4096');
  assert.strictEqual(config['cursor.ai.temperature'], 0.03, 'cursor.ai.temperature should be 0.03');
  assert.strictEqual(config['cursor.ai.contextLength'], 8192, 'cursor.ai.contextLength should be 8192');
  assert.strictEqual(config['cursor.ai.performance.memoryLimit'], 16384, 'cursor.ai.performance.memoryLimit should be 16384');
  assert.strictEqual(config['cursor.ai.performance.parallelRequests'], 8, 'cursor.ai.performance.parallelRequests should be 8');
  assert.strictEqual(config['cursor.ai.performance.responseTimeout'], 20000, 'cursor.ai.performance.responseTimeout should be 20000');
  console.log('ALL CURSOR AI SETTINGS VALIDATED SUCCESSFULLY');
} catch (err) {
  console.error('Cursor AI settings validation failed:', err.message);
  process.exit(1);
} 