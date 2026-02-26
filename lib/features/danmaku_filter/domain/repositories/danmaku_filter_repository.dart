import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/danmaku_filter/domain/entities/danmaku_filter_entity.dart';

/// Danmaku filter repository interface
abstract class DanmakuFilterRepository {
  /// Get danmaku filter rules
  Future<LoadingState<DanmakuFilterEntity>> getDanmakuFilter();

  /// Add danmaku filter rule
  Future<LoadingState<FilterRule>> addFilterRule({
    required String filter,
    required FilterRuleType type,
  });

  /// Delete danmaku filter rule
  Future<LoadingState<void>> deleteFilterRule({
    required int id,
  });
}
