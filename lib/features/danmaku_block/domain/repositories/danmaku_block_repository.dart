import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/user/danmaku_block.dart';

/// Repository interface for danmaku block rules
abstract class DanmakuBlockRepository {
  /// Fetch all danmaku block rules
  Future<LoadingState<DanmakuBlockDataModel>> getDanmakuFilterRules();

  /// Delete a danmaku block rule by ID
  Future<LoadingState<void>> deleteRule(int id);

  /// Add a new danmaku block rule
  Future<LoadingState<SimpleRule>> addRule({
    required String filter,
    required int type,
  });
}
