import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/danmaku_filter/domain/entities/danmaku_filter_entity.dart';
import 'package:PiliPlus/features/danmaku_filter/domain/repositories/danmaku_filter_repository.dart';

/// Add danmaku filter rule use case
class AddDanmakuFilterRule {
  final DanmakuFilterRepository repository;

  const AddDanmakuFilterRule(this.repository);

  Future<LoadingState<FilterRule>> call({
    required String filter,
    required FilterRuleType type,
  }) {
    return repository.addFilterRule(
      filter: filter,
      type: type,
    );
  }
}
