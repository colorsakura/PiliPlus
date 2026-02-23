import 'package:PiliPlus/features/history/domain/repositories/history_repository.dart';

/// 获取历史记录状态用例
class GetHistoryStatusUseCase {
  final HistoryRepository _repository;

  const GetHistoryStatusUseCase(this._repository);

  /// 执行用例：获取历史记录暂停状态
  ///
  /// 返回是否暂停记录历史
  Future<bool?> call() {
    return _repository.getHistoryStatus();
  }
}
