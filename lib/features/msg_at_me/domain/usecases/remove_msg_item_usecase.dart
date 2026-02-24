import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/msg_at_me/domain/repositories/msg_at_me_repository.dart';

/// Use case for removing a notification item
class RemoveMsgItemUseCase {
  const RemoveMsgItemUseCase(this._repository);

  final MsgAtMeRepository _repository;

  /// Execute the use case
  Future<LoadingState<void>> call({
    required Object id,
  }) =>
      _repository.removeMsgItem(id: id);
}
