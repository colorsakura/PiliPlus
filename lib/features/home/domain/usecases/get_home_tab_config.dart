import 'package:PiliPlus/features/home/domain/entities/home_tab_config.dart';
import 'package:PiliPlus/features/home/domain/repositories/home_tab_repository.dart';

/// 获取首页标签配置用例
class GetHomeTabConfigUseCase {
  final HomeTabRepository _repository;

  const GetHomeTabConfigUseCase(this._repository);

  /// 执行用例：获取首页标签配置
  Future<HomeTabConfig> call() => _repository.getHomeTabConfig();

  /// 保存标签排序
  Future<void> saveTabSort(List<int> sortIndices) async {
    await _repository.saveTabSort(sortIndices);
  }
}
