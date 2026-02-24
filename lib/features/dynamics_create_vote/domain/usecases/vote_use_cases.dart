import 'package:PiliPlus/features/dynamics_create_vote/domain/repositories/vote_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/vote_model.dart';

/// Use case for creating or updating a vote
///
/// Handles the logic for creating new votes or updating existing ones.
class CreateVote {
  final VoteRepository repository;

  CreateVote(this.repository);

  /// Execute the create/update vote use case
  ///
  /// [voteInfo] - The vote information to create or update
  ///
  /// Returns a loading state with the vote ID
  Future<LoadingState<int?>> call(VoteInfo voteInfo) {
    if (voteInfo.voteId == null) {
      return repository.createVote(voteInfo);
    } else {
      return repository.updateVote(voteInfo);
    }
  }
}

/// Use case for fetching vote information
///
/// Loads existing vote data for editing.
class GetVoteInfo {
  final VoteRepository repository;

  GetVoteInfo(this.repository);

  /// Execute the get vote info use case
  ///
  /// [voteId] - The vote ID to query
  ///
  /// Returns a loading state with the vote information
  Future<LoadingState<VoteInfo>> call(int voteId) {
    return repository.getVoteInfo(voteId);
  }
}

/// Use case for uploading vote option images
///
/// Uploads images for vote options.
class UploadVoteImage {
  final VoteRepository repository;

  UploadVoteImage(this.repository);

  /// Execute the upload vote image use case
  ///
  /// [index] - The option index
  /// [path] - The local file path
  ///
  /// Returns a loading state with the uploaded image URL
  Future<LoadingState<String?>> call(int index, String path) {
    return repository.uploadVoteImage(index, path);
  }
}
