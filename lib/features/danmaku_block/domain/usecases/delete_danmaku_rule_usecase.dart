import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/danmaku_block/domain/repositories/danmaku_block_repository.dart';

/// Use case for deleting a danmaku block rule
class DeleteDanmakuRuleUseCase {
  const DeleteDanmakuRuleUseCase(this._repository);

  final DanmakuBlockRepository _repository;

  Future<LoadingState<void>> call(int id) {
    return _repository.deleteRule(id);
  }
}
