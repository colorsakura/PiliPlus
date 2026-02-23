import 'package:PiliPlus/features/history/domain/entities/history_result.dart';
import 'package:PiliPlus/features/history/domain/repositories/history_repository.dart';

/// 获取历史记录用例
class FetchHistoryUseCase {
  final HistoryRepository _repository;

  const FetchHistoryUseCase(this._repository);

  /// 执行用例：获取历史记录列表
  ///
  /// [type] 历史类型，null表示全部
  /// [max] 分页最大ID
  /// [viewAt] 分页查看时间
  Future<HistoryResultEntity> call({
    String? type,
    int? max,
    int? viewAt,
  }) {
    return _repository.getHistoryList(
      type: type,
      max: max,
      viewAt: viewAt,
    );
  }
}
