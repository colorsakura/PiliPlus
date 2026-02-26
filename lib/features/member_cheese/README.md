# Member Cheese Feature

Displays member's cheese (Bangumi coin/subscription) content.

## Architecture

### Domain Layer
- **Repository**: Member cheese repository
- **Use Cases**: `FetchMemberCheese`

### Data Layer
- **Remote DataSource**: Member cheese remote data source
- **Repository Implementation**: Member cheese repository implementation

### Presentation Layer
- **Pages**: Member cheese content page
- **Controllers**: Cheese list controller

## Key Features

- **Cheese Content**: Subscription-only content
- **Purchase History**: Member's cheese purchases
- **Exclusive Access**: Premium/unlocked episodes

## Usage

```dart
// Fetch member's cheese content
final result = await fetchMemberCheese(mid: 123456);
```
