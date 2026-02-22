import 'package:PiliPlus/features/shell/domain/entities/navigation_config.dart';
import 'package:PiliPlus/features/shell/domain/repositories/navigation_repository.dart';

/// 获取导航配置用例
class GetNavigationConfigUseCase {
  final NavigationRepository _repository;

  const GetNavigationConfigUseCase(this._repository);

  /// 执行用例：获取导航配置
  Future<NavigationConfig> call() => _repository.getNavigationConfig();

  /// 保存导航栏排序
  Future<void> saveNavBarSort(List<int> sortIndices) async {
    await _repository.saveNavBarSort(sortIndices);
  }

  /// 更新默认首页索引
  Future<void> updateDefaultIndex(int index) async {
    await _repository.saveDefaultHomePageIndex(index);
  }
}
