import 'package:PiliPlus/http/danmaku_block.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/user/danmaku_block.dart';

/// Remote data source for danmaku block rules
class DanmakuBlockRemoteDatasource {
  const DanmakuBlockRemoteDatasource();

  /// Fetch all danmaku block rules via API
  Future<LoadingState<DanmakuBlockDataModel>> getDanmakuFilterRules() {
    return DanmakuFilterHttp.danmakuFilter();
  }

  /// Delete a danmaku block rule via API
  Future<LoadingState<void>> deleteRule(int id) {
    return DanmakuFilterHttp.danmakuFilterDel(ids: id);
  }

  /// Add a new danmaku block rule via API
  Future<LoadingState<SimpleRule>> addRule({
    required String filter,
    required int type,
  }) {
    return DanmakuFilterHttp.danmakuFilterAdd(
      filter: filter,
      type: type,
    );
  }
}
