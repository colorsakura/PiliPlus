import 'package:PiliPlus/http/loading_state.dart';

import '../entities/follow_up.dart';
import '../repositories/dynamics_repository.dart';

/// Use case for fetching follow-up UP users.
class FetchFollowUpUseCase {
  const FetchFollowUpUseCase(this._repository);

  final DynamicsRepository _repository;

  /// Fetch follow-up UP users.
  Future<LoadingState<FollowUpEntity>> call({
    String? offset,
  }) {
    return _repository.getFollowUp(offset: offset);
  }
}

/// Use case for fetching all followings.
class FetchAllFollowingsUseCase {
  const FetchAllFollowingsUseCase(this._repository);

  final DynamicsRepository _repository;

  /// Fetch all followings for a user.
  Future<LoadingState<List<UpItemEntity>>> call({
    required int mid,
    required int page,
  }) {
    return _repository.getAllFollowings(
      mid: mid,
      page: page,
    );
  }
}

/// Use case for fetching dynamics UP list.
class FetchDynamicsUpListUseCase {
  const FetchDynamicsUpListUseCase(this._repository);

  final DynamicsRepository _repository;

  /// Fetch dynamics UP list.
  Future<LoadingState<List<UpItemEntity>>> call({
    String? offset,
  }) {
    return _repository.getDynamicsUpList(offset: offset);
  }
}
