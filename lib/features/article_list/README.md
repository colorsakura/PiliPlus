# Article List Feature

Clean Architecture implementation for article list functionality.

## Overview

This feature handles fetching and displaying article collections. Users can view curated article lists with information about the collection, author, and individual articles.

## Architecture

### Domain Layer

**Entities:**
- `ArticleListDataEntity` - Encapsulates article list data including collection info, author, and article items

**Repository Interface:**
- `ArticleListRepository` - Abstract contract for article list operations

**Use Cases:**
- `GetArticleListUseCase` - Retrieve article list by collection ID

### Data Layer

**Data Sources:**
- `ArticleListRemoteDataSource` - Remote API data source for article lists
- `ArticleListRemoteDataSourceImpl` - Concrete implementation

**Models:**
- `ArticleListDataModel` - API response model for article list data

**Repositories:**
- `ArticleListRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `ArticleListPage` - Main page for displaying article collection

**Providers:**
- `ArticleListProvider` - Riverpod state management for article list

**Widgets:**
- `ArticleListItem` - Individual article item widget

## Usage

```dart
import 'package:PiliPlus/features/article_list/article_list.dart';

// Initialize repository and use case
final repository = ArticleListRepositoryImpl(
  remoteDataSource: ArticleListRemoteDataSourceImpl(),
);
final getArticleList = GetArticleListUseCase(repository);

// Get article list by ID
final result = await getArticleList('collection_id');

result.when(
  success: (data) {
    print('Collection: ${data.info?.name}');
    print('Author: ${data.author?.name}');
    print('Articles: ${data.items.length}');
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User navigates to article collection page
2. Presentation layer calls `GetArticleListUseCase` with collection ID
3. Use case invokes repository method
4. Repository fetches data from remote data source
5. Data is transformed to domain entity
6. Result is returned to presentation layer for UI rendering

## Entity Structure

`ArticleListDataEntity` contains:
- `info` - Collection metadata (name, cover image, statistics)
- `author` - Author information (name, avatar, etc.)
- `items` - List of articles in the collection

## Models Mapping

The entity is created from API response model:
- `ArticleListDataModel.list` → `ArticleListDataEntity.info`
- `ArticleListDataModel.author` → `ArticleListDataEntity.author`
- `ArticleListDataModel.articles` → `ArticleListDataEntity.items`
