# FavCreate Feature - Clean Architecture

This feature has been refactored to follow **Clean Architecture** principles.

## Architecture Layers

### Domain Layer (Core Business Logic)
- **Entities**: Core business objects
  - `FavFolderEntity`: Favorite folder information
  - `FavFolderParamsEntity`: Parameters for creating/editing folder

- **Repositories**: Abstract interfaces for data access
  - `FavFolderRepository`: Defines favorite folder operations contract

- **Use Cases**: Business logic operations
  - `GetFavFolderInfo`: Get folder information for editing
  - `CreateOrEditFavFolder`: Create new folder or edit existing one
  - `UploadFavCover`: Upload cover image

### Data Layer (Data Access)
- **Data Sources**: Raw data providers
  - `FavFolderRemoteDataSource` (interface): Abstract data source interface
  - `FavFolderRemoteDataSourceImpl`: Implementation using `FavHttp` and `MsgHttp`

- **Repositories**: Data repository implementations
  - `FavFolderRepositoryImpl`: Implements `FavFolderRepository` using remote data source

### Presentation Layer (UI)
- **Pages**: Screen widgets
  - `CreateFavPage`: Favorite folder create/edit page

- **Providers**: Dependency injection
  - `fav_create_providers.dart`: Riverpod providers for DI

## Dependency Flow

```
Presentation → Domain → Data
     ↓            ↓         ↓
   UI       Use Cases  Data Sources
            & Repos
```

## Key Features

1. **Create Folder**: Create new favorite folder
2. **Edit Folder**: Edit existing folder information
3. **Upload Cover**: Upload custom cover image
4. **Privacy Settings**: Control folder visibility (public/private)

## Usage Example

```dart
// Using providers in a widget
class FavCreateWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createOrEditFolder = ref.watch(createOrEditFavFolderUseCaseProvider);

    Future<void> submitFolder() async {
      final params = FavFolderParamsEntity(
        title: 'My Music Collection',
        intro: 'Best music videos',
        isPublic: true,
      );

      final result = await createOrEditFolder(params);

      result.when(
        success: (mediaId) {
          print('Folder created with ID: $mediaId');
          Get.back(result: mediaId);
        },
        error: (error) => print('Error: $error'),
      );
    }

    return ElevatedButton(
      onPressed: submitFolder,
      child: Text('Create Folder'),
    );
  }
}
```

## Technical Details

- Uses `FavHttp` for favorite folder operations
- Uses `MsgHttp` for image upload
- Supports image cropping on mobile platforms
- Handles both create and edit operations in single flow
- Validates title length (max 20 characters)
- Validates intro length (max 200 characters)

## Migration Notes

- The implementation wraps existing `FavHttp` and `MsgHttp` functionality
- The page still uses direct API calls for some operations for compatibility
- Image picker and cropper integration maintained at presentation layer
