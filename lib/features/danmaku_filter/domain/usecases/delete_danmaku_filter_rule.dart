import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/danmaku_filter/domain/repositories/danmaku_filter_repository.dart';

/// Delete danmaku filter rule use case
class DeleteDanmakuFilterRule {
  final DanmakuFilterRepository repository;

  const DeleteDanmakuFilterRule(this.repository);

  Future<LoadingState<void>> call({
    required int id,
  }) {
    return repository.deleteFilterRule(id: id);
  }
}
