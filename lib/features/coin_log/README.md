# Coin Log Feature

Clean Architecture implementation for coin log (coin transaction history) functionality.

## Overview

This feature handles displaying the user's coin transaction history. Users can view how they earned and spent coins over time with timestamps and reasons for each transaction.

## Architecture

### Domain Layer

**Entities:**
- `CoinLogItemEntity` - Represents a single coin transaction
- `CoinLogResultEntity` - Contains a list of coin log items

**Repository Interface:**
- `CoinLogRepository` - Abstract contract for coin log operations

**Use Cases:**
- `GetCoinLogUseCase` - Retrieve user's coin transaction history

### Data Layer

**Data Sources:**
- Remote API data source for coin logs

**Models:**
- `CoinLogItem` - API response model for coin log items

**Repositories:**
- `CoinLogRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `CoinLogPage` - Main page for displaying coin transaction history

**Providers:**
- `CoinLogController` - Controller for managing coin log state
- `CoinLogProvider` - Riverpod provider for coin log data

## Usage

```dart
import 'package:PiliPlus/features/coin_log/coin_log.dart';

// Initialize repository and use case
final repository = CoinLogRepositoryImpl(
  remoteDataSource: CoinLogRemoteDataSourceImpl(),
);
final getCoinLog = GetCoinLogUseCase(repository);

// Get coin transaction history
final result = await getCoinLog();

result.when(
  success: (logResult) {
    if (logResult.items != null) {
      for (var item in logResult.items!) {
        print('${item.time}: ${item.delta} - ${item.reason}');
      }
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User navigates to coin log page
2. Presentation layer calls `GetCoinLogUseCase`
3. Use case invokes repository method
4. Repository fetches data from remote data source
5. Data is transformed to domain entities
6. Result is returned to presentation layer for UI rendering
7. Transaction history is displayed with table format

## Entity Structure

**CoinLogItemEntity** contains:
- `time` - Timestamp of the transaction
- `delta` - Coin change amount (positive for earned, negative for spent)
- `reason` - Description of why the transaction occurred

**CoinLogResultEntity** contains:
- `items` - List of coin transaction items

## Display

The feature displays coin logs in a table format with:
- Header row (时间/变化/原因)
- One row per transaction
- Timestamp, change amount, and reason columns

## Coin System Context

Users earn coins through:
- Daily login bonus
- Watching videos
- Completing daily tasks

Users spend coins on:
- Tipping videos (up to 2 coins per video)
- Supporting creators
- Other platform features

## Model Mapping

The entity is created from API response model:
- `CoinLogItem` → `CoinLogItemEntity`
- Each field is mapped: `time`, `delta`, `reason`
- List of items → `CoinLogResultEntity.items`
