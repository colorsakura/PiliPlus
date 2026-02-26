# Exp Log Feature

Clean Architecture implementation for experience (XP) log functionality.

## Overview

This feature displays the user's experience point (level) gain history. Users can track how they've earned XP through various platform activities.

## Architecture

### Domain Layer

**Entities:**
- `ExpLogItem` - Individual XP log entry
- `ExpLogResultEntity` - Contains list of XP log entries

**Repository Interface:**
- `ExpLogRepository` - Abstract contract for XP log operations

**Use Cases:**
- `GetExpLogUseCase` - Retrieve XP gain history

### Data Layer

**Data Sources:**
- Remote API data source for XP logs

**Models:**
- XP log response models

**Repositories:**
- `ExpLogRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- XP log page

**Providers:**
- `ExpLogController` - Controller for managing XP log state
- `ExpLogProvider` - Riverpod provider for XP log data

## Usage

```dart
import 'package:PiliPlus/features/exp_log/exp_log.dart';

// Initialize repository and use case
final repository = ExpLogRepositoryImpl(
  remoteDataSource: ExpLogRemoteDataSourceImpl(),
);
final getExpLog = GetExpLogUseCase(repository);

// Get XP log
final result = await getExpLog();

result.when(
  success: (logResult) {
    print('XP entries: ${logResult.items.length}');
    for (var entry in logResult.items) {
      print('${entry.action}: +${entry.delta} XP');
      print('Date: ${entry.date}');
      print('Description: ${entry.reason}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User navigates to profile > XP log
2. Presentation layer calls `GetExpLogUseCase`
3. Use case invokes repository method
4. Repository fetches data from remote API
5. Data is transformed to domain entities
6. Results are displayed with XP history

## XP Sources

Users gain experience from:
- Daily login
- Watching videos
- Sharing content
- Commenting
- Liking/favoriting
- Sending gifts
- Other platform interactions

## Entity Structure

Each XP log entry contains:
- `action` - Action performed (e.g., "Watch Video")
- `delta` - XP gained from action
- `date` - When XP was earned
- `reason` - Description of the action
- `currentLevel` - Current level after gain
- `currentExp` - Current XP after gain

## Level System

The platform typically uses:
- Level 1-6 with daily XP caps
- Different activities give different XP amounts
- Level increases unlock new features
- Daily reset at midnight

## Use Cases

Users check XP log to:
- Track level progress
- Understand XP sources
- Verify daily XP gains
- Plan leveling strategy
- Review past activity
