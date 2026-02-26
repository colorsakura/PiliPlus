# PGC Review Feature

Clean Architecture implementation for PGC (anime/drama) review functionality.

## Overview

This feature manages user reviews for PGC content including anime, dramas, and other professional content. Users can read, write, like, and manage reviews.

## Architecture

### Domain Layer

**Entities:**
- `PgcReviewData` - Contains review list and metadata
- `PgcReviewType` - Review type enum

**Repository Interface:**
- `PgcReviewRepository` - Abstract contract for review operations

**Use Cases:**
- `GetPgcReviewUseCase` - Retrieve reviews for content
- `LikeReviewUseCase` - Like/upvote a review
- `DislikeReviewUseCase` - Remove like from review
- `DeleteReviewUseCase` - Delete own review

### Data Layer

**Data Sources:**
- `PgcReviewRemoteDataSource` - Remote API data source

**Models:**
- `PgcReviewData` - Review data model
- `PgcReviewType` - Type enumeration

**Repositories:**
- `PgcReviewRepositoryImpl` - Concrete implementation

### Presentation Layer

**Pages:**
- PGC review pages (v2 for Riverpod)

**Providers:**
- `PgcReviewController` - Controller for state
- `PgcReviewProvider` - Riverpod provider

## Usage

```dart
import 'package:PiliPlus/features/pgc_review/pgc_review.dart';

// Initialize repository and use cases
final repository = PgcReviewRepositoryImpl(
  remoteDataSource: PgcReviewRemoteDataSourceImpl(),
);
final getPgcReview = GetPgcReviewUseCase(repository);
final likeReview = LikeReviewUseCase(repository);

// Get reviews for a PGC content
final result = await getPgcReview(
  type: PgcReviewType.bangumi,
  mediaId: 12345,
  next: null,  // Pagination cursor
  sort: 1,     // Sort order
);

result.when(
  success: (data) {
    print('Reviews: ${data.list?.length ?? 0}');
    for (var review in data.list ?? []) {
      print('${review.author}: ${review.content}');
      print('Rating: ${review.score}');
      print('Likes: ${review.like}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);

// Like a review
final likeResult = await likeReview(
  mediaId: 12345,
  reviewId: 67890,
);
```

## Data Flow

1. User views PGC content details
2. User selects reviews section
3. Presentation layer calls `GetPgcReviewUseCase`
4. Repository fetches reviews from API
5. Reviews displayed with ratings and content
6. Users can interact via like/dislike

## Review Types

`PgcReviewType` enum:
- `bangumi` - Anime series reviews
- `movie` - Movie reviews
- `documentary` - Documentary reviews
- Other PGC content types

## Sort Options

Sort parameter controls order:
- `0` - Default sorting
- `1` - Most helpful first
- `2` - Latest first
- `3` - Highest rated

## Review Interactions

Users can:
- **Like** - Upvote helpful reviews
- **Dislike** - Remove upvote
- **Delete** - Remove own reviews

## Pagination

Cursor-based pagination:
- `next` - Cursor for next page
- Null for first page
- Update with returned next value

## Review Content

Each review includes:
- `author` - Reviewer information
- `content` - Review text
- `score` - Rating (usually 1-10)
- `like` - Number of likes
- `isLiked` - Current user's like status
- `ctime` - Creation time

## Use Cases

Reviews help users:
- Decide what to watch
- Share opinions
- Find quality content
- Express satisfaction
- Help community
