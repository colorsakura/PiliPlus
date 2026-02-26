# Space Setting Feature

Clean Architecture implementation for user space/profile settings functionality.

## Overview

This feature manages user profile (space) settings including privacy, display preferences, and other profile customization options.

## Architecture

### Domain Layer

**Entities:**
- `SpaceSettingData` - Contains all space setting options

**Repository Interface:**
- `SpaceSettingRepository` - Abstract contract for space settings operations

**Use Cases:**
- `GetSpaceSettingUseCase` - Retrieve current space settings
- `UpdateSpaceSettingModsUseCase` - Update specific setting modules

### Data Layer

**Data Sources:**
- `SpaceSettingRemoteDataSource` - Remote API data source

**Models:**
- `SpaceSettingData` - Space settings data model

**Repositories:**
- `SpaceSettingRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- Space settings page

**Providers:**
- `SpaceSettingController` - Controller for managing settings state
- `SpaceSettingProvider` - Riverpod provider for settings data

## Usage

```dart
import 'package:PiliPlus/features/space_setting/space_setting.dart';

// Initialize repository and use cases
final repository = SpaceSettingRepositoryImpl(
  remoteDataSource: SpaceSettingRemoteDataSourceImpl(),
);
final getSpaceSetting = GetSpaceSettingUseCase(repository);
final updateSpaceSettingMods = UpdateSpaceSettingModsUseCase(repository);

// Get current settings
final result = await getSpaceSetting();

result.when(
  success: (data) {
    print('Settings loaded');
    // Access various settings
    print('Favorite disabled: ${data.favDisabled}');
    print('Coin disabled: ${data.coinDisabled}');
  },
  error: (error) {
    print('Error: $error');
  },
);

// Update settings
final updateResult = await updateSpaceSettingMods({
  'coin_disabled': 1,
  'fav_disabled': 0,
});
```

## Data Flow

1. User navigates to profile settings
2. Presentation layer calls `GetSpaceSettingUseCase`
3. Use case invokes repository method
4. Repository fetches settings from remote API
5. Settings are displayed in UI
6. User modifies settings
7. Changes saved via `UpdateSpaceSettingModsUseCase`

## Setting Categories

### Favorites Settings
- `favDisabled` - Disable favorites display on profile
- Control who can see favorites

### Coin Settings
- `coinDisabled` - Disable coin display on profile
- Hide coin count from other users

### Privacy Settings
Various privacy controls for profile visibility and interaction

### Display Settings
Customize how profile appears to other users

## Update Format

Settings updates use key-value pairs:
```dart
{
  'setting_name': value,  // 0/1 for booleans, actual values for others
}
```

## Common Settings

Typical space settings include:
- Favorites visibility
- Coin count visibility
- Follower count display
- Following list visibility
- Like history visibility
- Comment display preferences

## Use Cases

Users adjust settings to:
- Control privacy
- Hide sensitive information
- Customize profile appearance
- Manage what others can see
- Reduce social pressure
