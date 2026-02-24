import 'package:PiliPlus/features/dynamics_tab/domain/repositories/dyn_tab_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for removing a dynamic
class RemoveDynamic {
  final DynTabRepository _repository;

  const RemoveDynamic(this._repository);

  Future<LoadingState> call({required String dynIdStr}) {
    return _repository.removeDynamic(dynIdStr: dynIdStr);
  }
}
