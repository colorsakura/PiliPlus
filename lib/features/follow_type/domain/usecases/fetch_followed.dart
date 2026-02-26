import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/features/follow_type/domain/repositories/follow_type_repository.dart';
import 'package:PiliPlus/features/follow_type/domain/entities/follow_type_params.dart';

/// Use case for fetching followers (users who follow the specified user)
class FetchFollowed {
  final FollowTypeRepository repository;

  const FetchFollowed(this.repository);

  /// Execute the fetch operation
  Future<LoadingState<FollowData>> call(FollowedParams params) {
    return repository.fetchFollowed(params);
  }
}
