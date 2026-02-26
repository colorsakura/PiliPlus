# Dynamics Create Feature

UI form for creating and editing dynamic posts, with Clean Architecture for publishing logic.

## Architecture

### Domain Layer
- **Entities**: `CreateDynamicParams`, `EditDynamicParams`
- **Repository**: `DynamicPublishRepository`
- **Use Cases**: `CreateDynamic`, `EditDynamic`

### Data Layer
- **Remote DataSource**: `DynamicPublishRemoteDataSource` / `DynamicPublishRemoteDataSourceImpl`
- **Repository Implementation**: `DynamicPublishRepositoryImpl`
- **HTTP Client**: Uses `DynamicsHttp` for API calls

### Presentation Layer
- **Pages**: `DynamicsCreatePage` (complex form with UI state management)

## Key Features

- **Rich Text Editing**: Support for text, images, emojis, mentions
- **Topic Selection**: Add and remove topics
- **Scheduled Publishing**: Set future publish time
- **Privacy Controls**: Private/public visibility
- **Reply Options**: Control who can reply
- **Attachments**: Reserve live stream cards
- **Edit Support**: Edit existing dynamics

## Usage

```dart
// Create a dynamic
final createDynamic = CreateDynamic(repository);
final result = await createDynamic(CreateDynamicParams(
  mid: userMid,
  rawText: 'Hello world!',
  pictures: imageList,
  replyOption: ReplyOptionType.allow,
));

// Edit a dynamic
final editDynamic = EditDynamic(repository);
await editDynamic(EditDynamicParams(
  dynId: dynId,
  rawText: 'Updated text',
  replyOption: ReplyOptionType.close,
));
```

## Architecture Notes

This feature separates business logic (publishing) from UI state management:
- **Domain/Data layers**: Handle API calls for create/edit operations
- **Presentation layer**: Manages form state, text editing, image selection, etc.

This pattern allows the complex UI form to focus on user interaction while the business logic is properly abstracted.
