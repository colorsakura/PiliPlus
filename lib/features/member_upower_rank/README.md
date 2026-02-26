# Member Upower Rank Feature

Displays member's UP (uploader) power ranking.

## Architecture

### Domain Layer
- **Repository**: Upower rank repository
- **Use Cases**: `FetchUpowerRank`

### Data Layer
- **Remote DataSource**: Upower rank remote data source
- **Repository Implementation**: Upower rank repository implementation

### Presentation Layer
- **Pages**: Upower rank display
- **Controllers**: Rank controller

## Key Features

- **Power Ranking**: Member's uploader influence score
- **Rank History**: Changes over time
- **Achievement Badges**: Milestone indicators

## Usage

```dart
// Fetch upower rank
final result = await fetchUpowerRank(mid: 123456);
```
