# Settings Search Feature

Clean Architecture implementation for settings search functionality.

## Overview

This feature handles searching within app settings. It provides real-time filtering of settings based on title and subtitle matching.

## Architecture

### Domain Layer

**Entities:**
- `SettingsSearchStateEntity` - Encapsulates search query and results with search logic

**Repository Interface:**
- `SettingsSearchRepository` - Abstract contract for settings search operations

**Use Cases:**
- `SearchSettings` - Perform settings search operations

### Data Layer

**Data Sources:**
- `SettingsSearchMemoryDataSource` - In-memory data source for search state
- `SettingsSearchMemoryDataSourceImpl` - Concrete implementation

**Repositories:**
- `SettingsSearchRepositoryImpl` - Concrete implementation managing search state

## Usage

```dart
import 'package:PiliPlus/features/settings_search/settings_search.dart';
import 'package:PiliPlus/features/setting/presentation/pages/models/model.dart';

// Initialize repository and use case
final repository = SettingsSearchRepositoryImpl(
  memoryDataSource: SettingsSearchMemoryDataSourceImpl(),
);
final searchSettings = SearchSettings(repository);

// Prepare all settings list
final allSettings = [
  ...extraSettings,
  ...privacySettings,
  ...recommendSettings,
  ...videoSettings,
  ...playSettings,
  ...styleSettings,
];

// Perform search
final result = searchSettings('dark', allSettings);

print('Found ${result.count} results');
print('Has results: ${result.hasResults}');

// Clear search
final clearedState = searchSettings.clear();
print('Cleared: ${clearedState.query.isEmpty}');
```

## Search Logic

The search is case-insensitive and matches against:
- `SettingsModel.effectiveTitle` - The display title of the setting
- `SettingsModel.effectiveSubtitle` - The subtitle/description (optional)

Empty query returns an empty result set. Clear search returns initial empty state.

## State Management

The feature uses in-memory state management via `SettingsSearchMemoryDataSource`. The state includes:
- Current search query
- Filtered results list

The presentation layer can listen to state changes and update the UI accordingly.

## Memory Data Source

Unlike other features that use remote data sources, this feature uses an in-memory data source because:
1. Search is performed locally on already-loaded settings
2. No network requests are needed
3. State is transient and doesn't need persistence

This pattern is appropriate for simple, client-side search functionality.
