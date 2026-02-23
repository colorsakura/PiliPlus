import 'package:PiliPlus/features/later/domain/repositories/later_repository.dart';

/// 移除稍后再看项用例
class RemoveLaterItemUseCase {
  final LaterRepository _repository;

  const RemoveLaterItemUseCase(this._repository);

  /// 执行移除稍后再看项
  ///
  /// [aids] 视频ID，多个用逗号分隔
  Future<bool> call(String aids) async {
    return await _repository.removeLaterItem(aids);
  }
}
