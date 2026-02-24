import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/vote_model.dart';

/// Repository for vote creation operations
///
/// Provides methods for creating and updating votes in dynamic posts.
abstract class VoteRepository {
  /// Get vote information by ID
  ///
  /// [voteId] - The vote ID to query
  /// Returns the vote information
  Future<LoadingState<VoteInfo>> getVoteInfo(int voteId);

  /// Create a new vote
  ///
  /// [voteInfo] - The vote information to create
  /// Returns the created vote ID
  Future<LoadingState<int?>> createVote(VoteInfo voteInfo);

  /// Update an existing vote
  ///
  /// [voteInfo] - The vote information to update
  /// Returns the updated vote ID
  Future<LoadingState<int?>> updateVote(VoteInfo voteInfo);

  /// Upload an image for a vote option
  ///
  /// [index] - The option index
  /// [path] - The local file path
  /// Returns the uploaded image URL
  Future<LoadingState<String?>> uploadVoteImage(int index, String path);
}
