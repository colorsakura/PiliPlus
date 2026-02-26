# Dynamics Select Topic Feature

Manages topic selection for dynamic posts.

## Architecture

### Domain Layer
- **Repository**: Topic repository interface
- **Use Cases**: `FetchTopicList`, `SearchTopics`

### Data Layer
- **Remote DataSource**: Topic remote data source
- **Repository Implementation**: Topic repository implementation

### Presentation Layer
- **Controllers**: `SelectTopicController`
- **Pages**: Topic selection panel

## Key Features

- **Topic List**: Browse trending and recommended topics
- **Search Topics**: Search for specific topics by keyword
- **Topic Selection**: Select and attach topics to dynamic posts
- **Save Position**: Remember scroll position for better UX

## Usage

```dart
// Select topic panel
SelectTopicPanel.onSelectTopic(
  context,
  offset: previousOffset,
  onCachePos: (offset) => saveOffset(offset),
);
```

## Integration

This feature provides the topic selection interface when creating or editing dynamics, allowing users to add context and discoverability through trending topics.
