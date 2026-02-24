import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';

import '../entities/dynamics_data.dart';
import '../repositories/dynamics_repository.dart';

/// Use case for fetching dynamics feed.
class FetchDynamicsUseCase {
  const FetchDynamicsUseCase(this._repository);

  final DynamicsRepository _repository;

  /// Fetch dynamics for a specific tab.
  Future<LoadingState<DynamicsDataEntity>> call({
    required DynamicsTabType tabType,
    String? offset,
  }) {
    return _repository.getDynamics(
      tabType: tabType,
      offset: offset,
    );
  }
}
