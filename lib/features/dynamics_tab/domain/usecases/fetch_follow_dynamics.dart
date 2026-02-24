import 'package:PiliPlus/features/dynamics_tab/domain/repositories/dyn_tab_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';

/// Use case for fetching follow dynamics
class FetchFollowDynamics {
  final DynTabRepository _repository;

  const FetchFollowDynamics(this._repository);

  Future<LoadingState<dynamic>> call({
    required DynamicsTabType type,
    required String offset,
    int? mid,
    required Set<int> tempBannedList,
  }) {
    return _repository.followDynamic(
      type: type,
      offset: offset,
      mid: mid,
      tempBannedList: tempBannedList,
    );
  }
}
