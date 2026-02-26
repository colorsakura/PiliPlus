# Whisper Settings Feature

Clean Architecture implementation for whisper (private message) settings management.

## Overview

This feature handles managing whisper (IM) settings for different types like notifications, privacy, etc. It allows users to view and update their whisper-related preferences.

## Architecture

### Domain Layer

**Entities:**
- `WhisperSettingsParams` - Parameters for fetching settings
- `WhisperSettingsResult` - Result containing page title and settings

**Repository Interface:**
- `WhisperSettingsRepository` - Abstract contract for settings operations

**Use Cases:**
- `FetchWhisperSettings` - Fetch whisper settings
- `UpdateWhisperSettings` - Update whisper settings

### Data Layer

**Data Sources:**
- `WhisperSettingsRemoteDataSource` - Interface for settings data source
- `WhisperSettingsRemoteDataSourceImpl` - Implementation using ImGrpc

**Repositories:**
- `WhisperSettingsRepositoryImpl` - Concrete implementation using remote data source

## Usage

### Fetch Settings

```dart
import 'package:PiliPlus/features/whisper_settings/whisper_settings.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart' show IMSettingType;

// Initialize repository and use case
final remoteDataSource = WhisperSettingsRemoteDataSourceImpl();
final repository = WhisperSettingsRepositoryImpl(
  remoteDataSource: remoteDataSource,
);
final fetchSettings = FetchWhisperSettings(repository);

// Prepare parameters
final params = WhisperSettingsParams(
  imSettingType: IMSettingType.IM_SETTING_TYPE_NOTIFY,
);

// Fetch settings
final result = await fetchSettings(params);

if (result case Success(:final response)) {
  print('Page: ${response.pageTitle}');
  print('Settings: ${response.settings.length}');
} else if (result case Error(:final errorMsg)) {
  print('Fetch failed: $errorMsg');
}
```

### Update Settings

```dart
final updateSettings = UpdateWhisperSettings(repository);

// Prepare settings map
final settings = {
  1: Setting()
    ..type = 1
    ..switchValue = true,
};

// Update settings
final result = await updateSettings(settings);

if (result case Success()) {
  print('Settings updated successfully');
} else if (result case Error(:final errorMsg)) {
  print('Update failed: $errorMsg');
}
```

## Setting Types

Whisper settings are categorized by `IMSettingType`:
- **NOTIFY** - Notification settings
- **PRIVACY** - Privacy settings
- And other types as defined in the gRPC schema

## Architecture Note

This feature uses `ImGrpc.getImSettings` and `ImGrpc.setImSettings` gRPC endpoints for settings management. The repository implementations wrap these gRPC calls, providing clean abstraction layers for the application logic.

## State Management

The presentation layer uses GetX controller (`WhisperSettingsController`) that extends `CommonDataController`. The controller manages:
- Settings data loading
- Page title
- Settings update operations
