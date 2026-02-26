# Emote Feature

Clean Architecture implementation for emote (emoji/sticker) panel functionality.

## Overview

This feature handles fetching and displaying emote packages for use in comments, messages, and other text inputs. It provides a categorized panel of emojis and stickers that users can insert.

## Architecture

### Domain Layer

**Entities:**
- `EmotePackageEntity` - Encapsulates a list of emote packages

**Repository Interface:**
- `EmoteRepository` - Abstract contract for emote operations

**Use Cases:**
- `GetEmotePackagesUseCase` - Retrieve emote packages for a specific business context

### Data Layer

**Data Sources:**
- `EmoteRemoteDataSource` - Remote API data source for emotes
- `EmoteRemoteDataSourceImpl` - Concrete implementation

**Models:**
- `Package` - API response model for emote packages

**Repositories:**
- `EmoteRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `EmotePanelPage` - Emote selection panel

**Providers:**
- `EmoteController` - Controller for managing emote state
- `EmoteProvider` - Riverpod provider for emote packages

## Usage

```dart
import 'package:PiliPlus/features/emote/emote.dart';

// Initialize repository and use case
final repository = EmoteRepositoryImpl(
  remoteDataSource: EmoteRemoteDataSourceImpl(),
);
final getEmotePackages = GetEmotePackagesUseCase(repository);

// Get emote packages for a business context
final result = await getEmotePackages(business: 'reply');

result.when(
  success: (packages) {
    if (packages != null) {
      for (var pkg in packages) {
        print('Package: ${pkg.name}');
        print('Emotes: ${pkg.emotes?.length}');
      }
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Business Contexts

The `business` parameter specifies where emotes will be used:

- `reply` - Comments/replies
- `dynamic` - Posts/dynamics
- `live` - Live room chat
- And other contexts defined by the platform

Different business contexts may return different emote packages.

## Data Flow

1. User opens emote panel (e.g., when writing a comment)
2. Presentation layer calls `GetEmotePackagesUseCase` with business context
3. Use case invokes repository method
4. Repository fetches data from remote data source
5. Data is returned (directly as models in this case)
6. Result is returned to presentation layer for UI rendering
7. User selects an emote to insert

## Entity Structure

**EmotePackageEntity** contains:
- `packages` - List of emote packages, where each package contains:
  - Package metadata (name, ID, etc.)
  - List of individual emotes
  - Each emote has URL, size, and other properties

## Emote Display

The presentation layer renders emotes as:
- Package tabs/categories
- Grid of emote images within each package
- Preview on hover/tap
- Insert on selection

## Model Mapping

Currently, the entity directly wraps the `Package` model. In a complete implementation:
1. Create pure domain entity for emotes
2. Map data layer models to domain entities in repository
3. Remove dependency on data layer models from domain layer
