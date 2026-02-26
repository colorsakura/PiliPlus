# Member Shop Feature

Displays member's shop (merchandise) content.

## Architecture

### Domain Layer
- **Repository**: Member shop repository
- **Use Cases**: `FetchMemberShop`

### Data Layer
- **Remote DataSource**: Member shop remote data source
- **Repository Implementation**: Member shop repository implementation

### Presentation Layer
- **Pages**: Member shop page
- **Controllers**: Shop items controller

## Key Features

- **Merchandise List**: Member's products for sale
- **Shop Stats**: Sales information, item details
- **Purchase Links**: Links to purchase items

## Usage

```dart
// Fetch member's shop
final result = await fetchMemberShop(mid: 123456);
```
