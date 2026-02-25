import 'package:PiliPlus/features/followed/domain/repositories/followed_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Use case for fetching "also followed" users list
class GetFollowedListUseCase {
  const GetFollowedListUseCase(this._repository);

  final FollowedRepository _repository;

  /// Execute the use case
  Future<LoadingState<FollowData>> call({
    required int mid,
    required int pn,
  }) => _repository.getFollowedList(
    mid: mid,
    pn: pn,
  );
}
