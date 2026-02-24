import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/user/danmaku_block.dart';
import 'package:PiliPlus/features/danmaku_block/domain/repositories/danmaku_block_repository.dart';

/// Use case for adding a danmaku block rule
class AddDanmakuRuleUseCase {
  const AddDanmakuRuleUseCase(this._repository);

  final DanmakuBlockRepository _repository;

  Future<LoadingState<SimpleRule>> call({
    required String filter,
    required int type,
  }) {
    return _repository.addRule(filter: filter, type: type);
  }
}
