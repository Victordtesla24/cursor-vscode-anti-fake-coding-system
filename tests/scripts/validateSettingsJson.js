#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const os = require('os');

// Path to the Cursor settings file
const settingsPath = path.join(os.homedir(), 'Library', 'Application Support', 'Cursor', 'User', 'settings.json');

let raw;
try {
  raw = fs.readFileSync(settingsPath, 'utf8');
} catch (err) {
  console.error(`Error reading settings file: ${err.message}`);
  process.exit(1);
}

let settings;
try {
  settings = JSON.parse(raw);
} catch (err) {
  console.error(`Invalid JSON: ${err.message}`);
  process.exit(1);
}

// Required settings with expected types
const requiredSettings = {
  'cursor.ai.enabled': 'boolean',
  'cursor.ai.model': 'string',
  'cursor.ai.maxTokens': 'number',
  'cursor.ai.temperature': 'number',
  'cursor.ai.streamResponse': 'boolean',
  'cursor.ai.contextLength': 'number',
  'cursor.ai.codeActions': 'boolean',
  'cursor.ai.chat.enabled': 'boolean',
  'cursor.ai.composer.enabled': 'boolean',
  'cursor.ai.codeGeneration.strictMode': 'boolean',
  'cursor.ai.codeGeneration.noMockCode': 'boolean',
  'cursor.ai.codeGeneration.noPlaceholders': 'boolean',
  'cursor.ai.codeGeneration.noTodoComments': 'boolean',
  'cursor.ai.codeGeneration.productionOnly': 'boolean',
  'cursor.ai.codeGeneration.completeImplementation': 'boolean',
  'cursor.ai.codeGeneration.noSafeMode': 'boolean',
  'cursor.ai.codeGeneration.noDryRun': 'boolean',
  'cursor.ai.performance.enableCache': 'boolean',
  'cursor.ai.performance.parallelRequests': 'number',
  'cursor.ai.performance.responseTimeout': 'number',
  'cursor.ai.performance.memoryLimit': 'number',
  'cursor.ai.fileEditing.atomicWrites': 'boolean',
  'cursor.ai.fileEditing.preventTruncation': 'boolean',
  'cursor.ai.fileEditing.validateSyntax': 'boolean',
  'cursor.ai.fileEditing.noDuplicates': 'boolean',
  'cursor.ai.fileEditing.noBackups': 'boolean'
};

let exitCode = 0;

// Validate presence and type
for (const [key, type] of Object.entries(requiredSettings)) {
  if (!(key in settings)) {
    console.error(`Missing setting: ${key}`);
    exitCode = 1;
  } else if (typeof settings[key] !== type) {
    console.error(`Invalid type for ${key}: expected ${type}, got ${typeof settings[key]}`);
    exitCode = 1;
  }
}

// Validate fixed values
if (settings['cursor.ai.model'] !== 'o4-mini') {
  console.error(`cursor.ai.model must be 'o4-mini', found '${settings['cursor.ai.model']}'`);
  exitCode = 1;
}
if (settings['cursor.ai.maxTokens'] !== 4096) {
  console.error(`cursor.ai.maxTokens must be 4096, found ${settings['cursor.ai.maxTokens']}`);
  exitCode = 1;
}
if (settings['cursor.ai.temperature'] !== 0.03) {
  console.error(`cursor.ai.temperature must be 0.03, found ${settings['cursor.ai.temperature']}`);
  exitCode = 1;
}

if (exitCode === 0) {
  console.log('All settings.json validation tests passed successfully.');
}
process.exit(exitCode); 