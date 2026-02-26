import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/danmaku_filter/domain/entities/danmaku_filter_entity.dart';
import 'package:PiliPlus/features/danmaku_filter/domain/repositories/danmaku_filter_repository.dart';

/// Get danmaku filter use case
class GetDanmakuFilter {
  final DanmakuFilterRepository repository;

  const GetDanmakuFilter(this.repository);

  Future<LoadingState<DanmakuFilterEntity>> call() {
    return repository.getDanmakuFilter();
  }
}
