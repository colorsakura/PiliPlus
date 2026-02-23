import 'package:PiliPlus/features/history/domain/repositories/history_repository.dart';

/// 删除历史记录用例
class DeleteHistoryUseCase {
  final HistoryRepository _repository;

  const DeleteHistoryUseCase(this._repository);

  /// 执行用例：删除历史记录
  ///
  /// [keys] 要删除的记录标识符列表
  Future<bool> call(List<String> keys) {
    return _repository.deleteHistory(keys);
  }
}
