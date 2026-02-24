import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/user/danmaku_block.dart';
import 'package:PiliPlus/features/danmaku_block/domain/repositories/danmaku_block_repository.dart';

/// Use case for fetching danmaku filter rules
class GetDanmakuFilterRulesUseCase {
  const GetDanmakuFilterRulesUseCase(this._repository);

  final DanmakuBlockRepository _repository;

  Future<LoadingState<DanmakuBlockDataModel>> call() {
    return _repository.getDanmakuFilterRules();
  }
}
