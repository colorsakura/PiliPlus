# About Feature

Clean Architecture implementation for the About/Settings page functionality.

## Overview

This feature handles the About page which displays application information, cache management, settings import/export, and update checking.

## Architecture

### Domain Layer

**Entities:**
- `AppInfoEntity` - Application metadata (name, version, build info, source URL)
- `CacheInfoEntity` - Cache size and file count information
- `ExportDataEntity` - Exported settings or login data

**Repository Interface:**
- `AboutRepository` - Abstract contract for about page operations

**Use Cases:**
- `GetAppInfoUseCase` - Retrieve application information
- `GetCacheInfoUseCase` - Get cache size and statistics
- `ClearCacheUseCase` - Clear application cache
- `ExportSettingsUseCase` - Export user settings to JSON
- `ImportSettingsUseCase` - Import settings from JSON
- `CheckUpdateUseCase` - Check for app updates

### Data Layer

**Data Sources:**
- `AboutLocalDataSource` - Local data source for app info and cache

**Repositories:**
- `AboutRepositoryImpl` - Concrete implementation using local data source

### Presentation Layer

**Pages:**
- `AboutPage` - Main about page with app info and options

## Usage

```dart
import 'package:PiliPlus/features/about/about.dart';

// Initialize repository and use cases
final repository = AboutRepositoryImpl(
  localDataSource: AboutLocalDataSourceImpl(),
);
final getAppInfo = GetAppInfoUseCase(repository);
final getCacheInfo = GetCacheInfoUseCase(repository);
final clearCache = ClearCacheUseCase(repository);

// Get application information
final appInfo = await getAppInfo();
print('App: ${appInfo.appName}');
print('Version: ${appInfo.fullVersion}');
print('Build: ${appInfo.buildTime}');

// Get cache information
final cacheInfo = await getCacheInfo();
print('Cache size: ${cacheInfo.size}');

// Clear cache
final success = await clearCache();
if (success) {
  print('Cache cleared successfully');
}
```

## Data Flow

1. User opens About page
2. Presentation layer loads app info via `GetAppInfoUseCase`
3. Cache info is loaded via `GetCacheInfoUseCase`
4. User can clear cache via `ClearCacheUseCase`
5. Settings can be exported/imported for backup
6. User can check for updates

## Entity Structure

**AppInfoEntity** contains:
- `appName` - Application name
- `versionName` - Display version (e.g., "1.2.3")
- `versionCode` - Integer version code
- `fullVersion` - Complete version string with build info
- `buildTime` - Unix timestamp of build time
- `commitHash` - Git commit hash
- `sourceCodeUrl` - Repository URL
- Computed: `commitUrl` - URL to specific commit
- Computed: `issuesUrl` - URL to issue tracker

**CacheInfoEntity** contains:
- `size` - Total cache size in bytes
- `count` - Number of cached files

**ExportDataEntity** contains:
- `jsonData` - Exported data as JSON
- `timestamp` - Export timestamp

## Features

### App Information
- Displays app name and version
- Shows build time and commit hash
- Links to source code and issues
- Provides commit and issue URLs

### Cache Management
- Calculates cache size
- Shows number of cached files
- Provides clear cache functionality
- Updates after clearing

### Settings Management
- Export settings to JSON file
- Import settings from JSON file
- Reset exportable settings to defaults
- Reset all data (including login info)

### Update Checking
- Checks for new app version
- Shows update notification if available
- Optional: show message even if no update

## Import/Export

Settings can be exported and imported for:
- Backup user preferences
- Transfer settings between devices
- Quick recovery after reset

Login info can also be exported separately for:
- Session backup
- Cross-device login sync
