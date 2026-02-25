import 'package:PiliPlus/features/follow_same/domain/repositories/follow_same_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Use case for fetching "same followed" users list
class GetSameFollowListUseCase {
  const GetSameFollowListUseCase(this._repository);

  final FollowSameRepository _repository;

  /// Execute the use case
  Future<LoadingState<FollowData>> call({
    required int mid,
    required int pn,
  }) => _repository.getSameFollowList(
    mid: mid,
    pn: pn,
  );
}
