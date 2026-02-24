import 'package:PiliPlus/features/dynamics_detail/domain/repositories/dyn_detail_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for setting dynamic visibility
class SetPubSetting {
  final DynDetailRepository _repository;

  const SetPubSetting(this._repository);

  Future<LoadingState> call({
    required Object dynId,
    required String action,
  }) {
    return _repository.setPubSetting(dynId: dynId, action: action);
  }
}
