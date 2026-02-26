# PGC Index Feature

Clean Architecture implementation for PGC (Professional Generated Content) index functionality.

## Overview

This feature handles browsing and searching PGC content (anime/dramas). It provides index conditions (filters) and search results for PGC content.

## Architecture

### Domain Layer

**Entities:**
- `PgcIndexItemEntity` - Represents a single PGC item (season ID, title, cover, score, etc.)
- `PgcIndexResultEntity` - Contains PGC items list and pagination info

**Repository Interface:**
- `PgcIndexRepository` - Abstract contract for PGC index operations

**Use Cases:**
- `GetPgcIndexConditionUseCase` - Retrieve filter conditions for PGC search
- `GetPgcIndexResultUseCase` - Retrieve PGC search results with filters

### Data Layer

**Data Sources:**
- `PgcIndexRemoteDataSource` - Remote API data source for PGC index
- `PgcIndexRemoteDataSourceImpl` - Concrete implementation

**Models:**
- `PgcIndexConditionData` - API response for index conditions
- `PgcIndexItem` - API response model for PGC items

**Repositories:**
- `PgcIndexRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `PgcIndexPage` - Main page for PGC content browsing

**Providers:**
- `PgcIndexController` - Controller for managing index state
- `PgcIndexProvider` - Riverpod state management for PGC index

## Usage

```dart
import 'package:PiliPlus/features/pgc_index/pgc_index.dart';

// Initialize repository and use cases
final repository = PgcIndexRepositoryImpl(
  remoteDataSource: PgcIndexRemoteDataSourceImpl(),
);
final getCondition = GetPgcIndexConditionUseCase(repository);
final getResult = GetPgcIndexResultUseCase(repository);

// Get filter conditions
final conditionResult = await getCondition(indexType: 1);
conditionResult.when(
  success: (condition) {
    print('Available filters: ${condition.filters}');
  },
  error: (error) {
    print('Error: $error');
  },
);

// Get search results
final searchResult = await getResult(
  page: 1,
  params: {'year': '2024', 'style': 'action'},
  indexType: 1,
);
searchResult.when(
  success: (items) {
    print('Found ${items?.length} results');
    print('Has more: ${result.hasNext}');
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User opens PGC index page
2. Presentation layer calls `GetPgcIndexConditionUseCase` to get available filters
3. User selects filter options
4. Presentation layer calls `GetPgcIndexResultUseCase` with selected filters
5. Use case invokes repository method
6. Repository fetches data from remote data source
7. Data is transformed to domain entities
8. Result is returned to presentation layer for UI rendering

## Entity Structure

**PgcIndexItemEntity** contains:
- `seasonId` - Season/series identifier
- `title` - Content title
- `cover` - Cover image URL
- `score` - Rating score
- `indexShow` - Display label
- `isFinish` - Completion status
- `seasonStatus` - Season status flag

**PgcIndexResultEntity** contains:
- `items` - List of PGC items
- `hasNext` - Whether more pages exist

## Models Mapping

Entities are created from API response models:
- `PgcIndexItem` model → `PgcIndexItemEntity`
- `PgcIndexItem` list → `PgcIndexResultEntity.items`

## Filtering

The feature supports filtering by:
- Year
- Style/Genre
- Production region
- Season status
- Completion status
- And more (defined by PGC index condition API)
