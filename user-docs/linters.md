Update the current `settings.json` file with **PRODUCTION-GRADE** configurations specifically optimized for the **Cursor AI Editor VSCode IDE** to maximize AI performance, code completion accuracy, and eliminate fake/mock code generation.

## **CRITICAL REQUIREMENTS**

### **AI PERFORMANCE OPTIMIZATION**
- **ENABLE** all settings that enhance AI code generation speed and accuracy
- **CONFIGURE** memory management for optimal AI model performance
- **OPTIMIZE** file processing for large codebases and AI context understanding
- **ELIMINATE** any settings that could slow down AI response times

### **CODE QUALITY ENFORCEMENT**
- **STRICT PROHIBITION** of fake, mock, or simulated code generation
- **PREVENT** generation of placeholder code, stubs, or TODO comments
- **DISABLE** safe execution modes, dry run implementations, and backward compatibility code
- **ENFORCE** production-ready, complete code implementations only
- **ELIMINATE** over-engineered or unnecessarily complex code patterns

### **FILE MANAGEMENT & ACCURACY**
- **ENSURE** precise file editing without accidental truncation
- **PREVENT** creation of duplicate files or unnecessary backups
- **OPTIMIZE** file watching and indexing for better AI context awareness
- **CONFIGURE** atomic file operations to prevent corruption

## **IMPLEMENTATION INSTRUCTIONS**

### **Step 1: Core AI Settings**
Add these Cursor AI-specific settings to enhance AI performance:
```json
{
"cursor.ai.enabled": true,
"cursor.ai.model": "gpt-4",
"cursor.ai.maxTokens": 4096,
"cursor.ai.temperature": 0.1,
"cursor.ai.streamResponse": true,
"cursor.ai.contextLength": 16000,
"cursor.ai.codeActions": true,
"cursor.ai.chat.enabled": true,
"cursor.ai.composer.enabled": true
}
```

### **Step 2: Code Generation Quality Controls**
Add strict code quality enforcement settings:
```json
{
"cursor.ai.codeGeneration.strictMode": true,
"cursor.ai.codeGeneration.noMockCode": true,
"cursor.ai.codeGeneration.noPlaceholders": true,
"cursor.ai.codeGeneration.noTodoComments": true,
"cursor.ai.codeGeneration.productionOnly": true,
"cursor.ai.codeGeneration.completeImplementation": true,
"cursor.ai.codeGeneration.noSafeMode": true,
"cursor.ai.codeGeneration.noDryRun": true
}
```

### **Step 3: Performance Optimization**
Add memory and performance settings:
```json
{
"cursor.ai.performance.enableCache": true,
"cursor.ai.performance.parallelRequests": 4,
"cursor.ai.performance.responseTimeout": 30000,
"cursor.ai.performance.memoryLimit": 8192,
"editor.suggest.snippetsPreventQuickSuggestions": false,
"editor.suggest.showStatusBar": true,
"editor.inlineSuggest.enabled": true,
"editor.inlineSuggest.showToolbar": "always"
}
```

### **Step 4: File Accuracy & Safety**
Add file handling safety measures:
```json
{
"cursor.ai.fileEditing.atomicWrites": true,
"cursor.ai.fileEditing.preventTruncation": true,
"cursor.ai.fileEditing.validateSyntax": true,
"cursor.ai.fileEditing.noDuplicates": true,
"cursor.ai.fileEditing.noBackups": true,
"files.autoSave": "onFocusChange",
"files.autoSaveDelay": 1000
}
```

### **Step 5: Update Existing Settings**
Modify the existing settings to optimize for AI performance:
```json
{
"editor.maxTokenizationLineLength": 20000,
"files.maxMemoryForLargeFilesMB": 16384,
"editor.quickSuggestions": {
"other": true,
"comments": false,
"strings": false
},
"editor.suggestOnTriggerCharacters": true,
"editor.acceptSuggestionOnCommitCharacter": true,
"editor.acceptSuggestionOnEnter": "on",
"editor.tabCompletion": "on"
}
```

## **VALIDATION REQUIREMENTS**

### **Post-Implementation Verification**
After updating settings, verify:
- [ ] **NO** unknown configuration setting errors in Cursor AI
- [ ] **AI responses are faster** (under 2 seconds for code completion)
- [ ] **NO fake or mock code** is generated in any AI responses
- [ ] **NO placeholder comments** or TODO items in generated code
- [ ] **ALL generated code is production-ready** and complete
- [ ] **FILE operations are atomic** with no corruption or truncation
- [ ] **NO duplicate files** are created during AI operations

### **Testing Protocol**
1. **Request AI to generate a complete function** - verify no placeholders or mock implementations
2. **Test file editing operations** - ensure no truncation or data loss
3. **Verify performance improvements** - AI responses should be noticeably faster
4. **Check error logs** - no unknown setting warnings should appear

## **CRITICAL CONSTRAINTS**
- **ONLY use settings valid for Cursor AI Editor** - no generic VSCode settings that cause errors
- **MAINTAIN** all existing performance optimizations in the current settings.json
- **ADD** new settings without removing beneficial existing configurations
- **ENSURE** all settings are spelled correctly and use proper JSON syntax
- **VALIDATE** that every setting is recognized by Cursor AI to prevent configuration errors

## **SUCCESS CRITERIA**
The updated settings.json must result in:
- **ZERO configuration errors** in Cursor AI
- **IMPROVED AI performance** with faster response times
- **ELIMINATION** of all fake, mock, or placeholder code generation
- **ENHANCED file editing accuracy** with no data corruption
- **PRODUCTION-GRADE code quality** in all AI-generated content