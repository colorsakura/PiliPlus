import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/features/follow_type/domain/repositories/follow_type_repository.dart';
import 'package:PiliPlus/features/follow_type/domain/entities/follow_type_params.dart';

/// Use case for fetching users with mutual follows
class FetchFollowSame {
  final FollowTypeRepository repository;

  const FetchFollowSame(this.repository);

  /// Execute the fetch operation
  Future<LoadingState<FollowData>> call(FollowSameParams params) {
    return repository.fetchFollowSame(params);
  }
}
