import 'package:PiliPlus/features/shell/data/datasources/navigation_local_datasource.dart';
import 'package:PiliPlus/features/shell/domain/entities/navigation_config.dart';
import 'package:PiliPlus/features/shell/domain/repositories/navigation_repository.dart';
import 'package:PiliPlus/models/common/bar_hide_type.dart';

/// 导航配置仓库实现
class NavigationRepositoryImpl implements NavigationRepository {
  final NavigationLocalDataSource _localDataSource;

  NavigationRepositoryImpl({
    required NavigationLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<NavigationConfig> getNavigationConfig() async {
    final navigationBars = _localDataSource.getNavBarSort();
    final selectedIndex = _localDataSource.getDefaultHomePageIndex();
    final hideBottomBar = _localDataSource.getHideBottomBar();
    final barHideType = _localDataSource.getBarHideType();
    final defaultHomePageIndex = _localDataSource.getDefaultHomePageIndex();

    return NavigationConfig(
      navigationBars: navigationBars,
      selectedIndex: selectedIndex,
      hideBottomBar: hideBottomBar,
      barHideType: barHideType,
      useBottomNav: false, // 由 UI 层根据屏幕方向设置
      defaultHomePageIndex: defaultHomePageIndex,
    );
  }

  @override
  Future<void> saveNavBarSort(List<int> sortIndices) async {
    await _localDataSource.saveNavBarSort(sortIndices);
  }

  @override
  Future<void> saveDefaultHomePageIndex(int index) async {
    await _localDataSource.saveDefaultHomePageIndex(index);
  }

  @override
  Future<bool> getHideBottomBar() async {
    return _localDataSource.getHideBottomBar();
  }

  @override
  Future<BarHideType> getBarHideType() async {
    return _localDataSource.getBarHideType();
  }

  @override
  Future<bool> getOptTabletNav() async {
    return _localDataSource.getOptTabletNav();
  }
}
