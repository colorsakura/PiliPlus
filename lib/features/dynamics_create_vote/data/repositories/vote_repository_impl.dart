import 'package:PiliPlus/features/dynamics_create_vote/data/datasources/vote_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_create_vote/domain/repositories/vote_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/vote_model.dart';

/// Implementation of vote repository
///
/// Provides access to vote data through remote data source.
class VoteRepositoryImpl implements VoteRepository {
  final VoteRemoteDatasource remoteDatasource;

  VoteRepositoryImpl({required this.remoteDatasource});

  @override
  Future<LoadingState<VoteInfo>> getVoteInfo(int voteId) {
    return remoteDatasource.getVoteInfo(voteId);
  }

  @override
  Future<LoadingState<int?>> createVote(VoteInfo voteInfo) {
    return remoteDatasource.createVote(voteInfo);
  }

  @override
  Future<LoadingState<int?>> updateVote(VoteInfo voteInfo) {
    return remoteDatasource.updateVote(voteInfo);
  }

  @override
  Future<LoadingState<String?>> uploadVoteImage(int index, String path) {
    return remoteDatasource.uploadVoteImage(index, path);
  }
}
