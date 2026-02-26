# Dynamics Create Vote Feature

Manages voting functionality for dynamic posts.

## Architecture

### Domain Layer
- **Repository**: `DynVoteRepository` (interface for vote operations)
- **Use Cases**: `CreateVote`, `UpdateVote`, `DeleteVote`

### Data Layer
- **Remote DataSource**: `DynVoteRemoteDataSource`
- **Repository Implementation**: `DynVoteRepositoryImpl`
- **HTTP Client**: Uses Dynamics HTTP API

### Presentation Layer
- **Pages**: `CreateVotePage`
- **Providers**: `VoteController`, `voteProvider`

## Key Features

- **Create Vote**: Create new poll with multiple options
- **Update Vote**: Modify existing vote content
- **Delete Vote**: Remove vote from dynamic
- **Vote Options**: Support for multiple choice options

## Usage

```dart
// Create a vote
final createVote = CreateVote(repository);
await createVote(params);

// Update vote
final updateVote = UpdateVote(repository);
await updateVote(params);

// Delete vote
final deleteVote = DeleteVote(repository);
await deleteVote(voteId);
```

## Integration

This feature allows users to create interactive polls within their dynamic posts, increasing engagement and gathering audience opinions.
