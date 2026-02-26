# Member Dynamics Feature

Displays a member's dynamic posts.

## Architecture

### Domain Layer
- **Repository**: Member dynamics repository
- **Use Cases**: `FetchMemberDynamics`

### Data Layer
- **Remote DataSource**: Member dynamics remote data source
- **Repository Implementation**: Member dynamics repository implementation

### Presentation Layer
- **Pages**: Member dynamics timeline
- **Controllers**: Dynamics feed controller

## Key Features

- **Dynamic Feed**: Paginated member's dynamic posts
- **Media Support**: Images, videos, articles in dynamics
- **Interaction**: Like, comment, share functionality

## Usage

```dart
// Fetch member dynamics
final result = await fetchMemberDynamics(
  mid: 123456,
  page: 1,
);
```
