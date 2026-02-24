import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/dynamics/vote_model.dart';

/// Remote data source for vote operations
///
/// Fetches and submits vote data to the Bilibili API.
class VoteRemoteDatasource {
  /// Get vote information by ID
  ///
  /// [voteId] - The vote ID to query
  /// Returns the vote information
  Future<LoadingState<VoteInfo>> getVoteInfo(int voteId) {
    return DynamicsHttp.voteInfo(voteId);
  }

  /// Create a new vote
  ///
  /// [voteInfo] - The vote information to create
  /// Returns the created vote ID
  Future<LoadingState<int?>> createVote(VoteInfo voteInfo) {
    return DynamicsHttp.createVote(voteInfo);
  }

  /// Update an existing vote
  ///
  /// [voteInfo] - The vote information to update
  /// Returns the updated vote ID
  Future<LoadingState<int?>> updateVote(VoteInfo voteInfo) {
    return DynamicsHttp.updateVote(voteInfo);
  }

  /// Upload an image for a vote option
  ///
  /// [index] - The option index (unused in API but kept for interface consistency)
  /// [path] - The local file path
  /// Returns the uploaded image URL
  Future<LoadingState<String?>> uploadVoteImage(int index, String path) async {
    final res = await MsgHttp.uploadBfs(
      path: path,
      category: 'daily',
      biz: 'vote',
    );

    if (res case Success(:final response)) {
      return Success(response.imageUrl);
    } else {
      final error = res as Error;
      return Error(error.errMsg, code: error.code);
    }
  }
}
