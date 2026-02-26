# Danmaku Filter Feature

Clean Architecture implementation for danmaku (bullet comment) filtering functionality.

## Overview

This feature handles filtering of danmaku (bullet comments) in videos and live streams. Users can create filter rules to block unwanted comments based on:
- Keywords - Block specific words or phrases
- Regex - Block comments matching a regular expression
- Users - Block comments from specific users

## Architecture

### Domain Layer

**Entities:**
- `DanmakuFilterEntity` - Container for all filter rules
- `FilterRule` - Individual filter rule with id, filter content, and type
- `FilterRuleType` - Enum for filter types (keyword, regex, user)

**Repository Interface:**
- `DanmakuFilterRepository` - Abstract contract for filter operations

**Use Cases:**
- `GetDanmakuFilter` - Fetch all filter rules
- `AddDanmakuFilterRule` - Add a new filter rule
- `DeleteDanmakuFilterRule` - Delete a filter rule

### Data Layer

**Data Sources:**
- `DanmakuFilterRemoteDataSource` - HTTP client for danmaku filter API endpoints

**Repositories:**
- `DanmakuFilterRepositoryImpl` - Concrete implementation with error handling

## Usage

```dart
import 'package:PiliPlus/features/danmaku_filter/danmaku_filter.dart';

// Initialize repository and use cases
final repository = DanmakuFilterRepositoryImpl(
  remoteDataSource: DanmakuFilterRemoteDataSource(),
);

final getFilter = GetDanmakuFilter(repository);
final addRule = AddDanmakuFilterRule(repository);
final deleteRule = DeleteDanmakuFilterRule(repository);

// Get all filter rules
final result = await getFilter();

if (result case Success(:final filter)) {
  print('Total rules: ${filter.totalCount}');
  print('Keyword rules: ${filter.keywordRules.length}');
  print('Regex rules: ${filter.regexRules.length}');
  print('User rules: ${filter.userRules.length}');
}

// Add a new keyword filter
final addResult = await addRule(
  filter: 'spam',
  type: FilterRuleType.keyword,
);

// Delete a filter rule
await deleteRule(id: 123);
```

## Filter Types

| Type | Value | Description |
|------|-------|-------------|
| `keyword` | 0 | Block specific words or phrases |
| `regex` | 1 | Block comments matching a regex pattern |
| `user` | 2 | Block all comments from specific users |

## API Operations

The `DanmakuFilterRemoteDataSource` provides:

| Method | Description |
|--------|-------------|
| `danmakuFilter` | Get all filter rules |
| `danmakuFilterAdd` | Add a new filter rule |
| `danmakuFilterDel` | Delete a filter rule |

## Error Handling

The repository catches `ServerException` and general `Exception`, converting them to `LoadingState` for consistent error handling in the presentation layer.

Common error messages:
- '获取弹幕过滤规则失败' - Failed to get filter rules
- '添加弹幕过滤规则失败' - Failed to add filter rule
- '删除弹幕过滤规则失败' - Failed to delete filter rule
