# Danmaku Block Feature

Clean Architecture implementation for danmaku (bullet comments) filtering functionality.

## Overview

This feature manages user-defined rules for filtering unwanted danmaku (bullet comments). Users can create, view, and delete filter rules to customize their viewing experience.

## Architecture

### Domain Layer

**Entities:**
- `DanmakuBlockDataModel` - Contains all filter rules
- `SimpleRule` - Individual filter rule

**Repository Interface:**
- `DanmakuBlockRepository` - Abstract contract for filter rule operations

**Use Cases:**
- `GetDanmakuFilterRulesUseCase` - Retrieve all filter rules
- `DeleteDanmakuRuleUseCase` - Delete a filter rule
- `AddDanmakuRuleUseCase` - Add a new filter rule

### Data Layer

**Data Sources:**
- `DanmakuBlockRemoteDataSource` - Remote API data source

**Models:**
- `DanmakuBlockDataModel` - Filter rules data model
- `SimpleRule` - Simple rule model

**Repositories:**
- `DanmakuBlockRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `DanmakuBlockPageV2` - Main page for managing filter rules

**Providers:**
- `DanmakuBlockController` - Controller for managing rules state
- `DanmakuBlockProvider` - Riverpod provider for rules data

## Usage

```dart
import 'package:PiliPlus/features/danmaku_block/danmaku_block.dart';

// Initialize repository and use cases
final repository = DanmakuBlockRepositoryImpl(
  remoteDataSource: DanmakuBlockRemoteDataSourceImpl(),
);
final getRules = GetDanmakuFilterRulesUseCase(repository);
final deleteRule = DeleteDanmakuRuleUseCase(repository);
final addRule = AddDanmakuRuleUseCase(repository);

// Get all filter rules
final result = await getRules();

result.when(
  success: (data) {
    print('Rules: ${data.rules?.length ?? 0}');
    for (var rule in data.rules ?? []) {
      print('Filter: ${rule.filter}, Type: ${rule.type}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);

// Add a new rule
final addResult = await addRule(
  filter: 'spam',
  type: 0,  // Rule type
);

// Delete a rule
final deleteResult = await deleteRule(123);
```

## Data Flow

1. User opens danmaku filter settings
2. Presentation layer calls `GetDanmakuFilterRulesUseCase`
3. Use case invokes repository method
4. Repository fetches rules from remote API
5. Rules are displayed in UI
6. User can add new rules via `AddDanmakuRuleUseCase`
7. User can delete rules via `DeleteDanmakuRuleUseCase`

## Rule Types

Danmaku filter rules support various types:
- `0` - Keyword filtering (text contains)
- `1` - Regex filtering (pattern matching)
- `2` - User filtering (block specific users)
- Other types as defined by platform

## Rule Properties

Each filter rule contains:
- `id` - Unique rule identifier
- `filter` - Filter pattern (keyword or regex)
- `type` - Rule type (keyword, regex, user, etc.)
- `enabled` - Whether rule is active
- `createdAt` - Creation timestamp

## Filter Application

Rules are applied to danmaku in order:
1. Check each incoming danmaku
2. Apply rules in priority order
3. Hide danmaku if it matches any rule
4. Display remaining danmaku

## Common Use Cases

Users create rules to filter:
- Spam or advertisement keywords
- Offensive language
- Spoiler content
- Specific users
- Repetitive messages
- Unwanted topics

## Rule Management

- Add new rules with filter text and type
- Delete rules by ID
- Enable/disable rules (not yet implemented)
- Edit existing rules (not yet implemented)
- Reorder rule priority (not yet implemented)
