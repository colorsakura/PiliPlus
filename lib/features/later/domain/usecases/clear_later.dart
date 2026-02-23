import 'package:PiliPlus/features/later/domain/repositories/later_repository.dart';

/// 清空稍后再看用例
class ClearLaterUseCase {
  final LaterRepository _repository;

  const ClearLaterUseCase(this._repository);

  /// 执行清空稍后再看
  ///
  /// [cleanType] 清空类型: 1-清空失效, 2-清空看完, null-清空全部
  Future<bool> call([int? cleanType]) async {
    return await _repository.clearLater(cleanType);
  }
}
