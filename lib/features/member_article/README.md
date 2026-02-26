# Member Article Feature

Displays a member's published articles.

## Architecture

### Domain Layer
- **Repository**: Member article repository
- **Use Cases**: `FetchMemberArticles`

### Data Layer
- **Remote DataSource**: Member article remote data source
- **Repository Implementation**: Member article repository implementation

### Presentation Layer
- **Pages**: Member article list page
- **Controllers**: Article list controller with pagination

## Key Features

- **Article List**: Paginated list of member's articles
- **Sort Options**: By date, popularity, etc.
- **Article Stats**: View count, like count, comment count

## Usage

```dart
// Fetch member articles
final result = await fetchMemberArticles(
  mid: 123456,
  page: 1,
  sort: 'pubdate',
);
```
