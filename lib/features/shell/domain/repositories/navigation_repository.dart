import 'package:PiliPlus/features/shell/domain/entities/navigation_config.dart';
import 'package:PiliPlus/models/common/bar_hide_type.dart';

/// 导航配置仓库接口
abstract interface class NavigationRepository {
  /// 获取导航配置
  Future<NavigationConfig> getNavigationConfig();

  /// 保存导航栏排序
  Future<void> saveNavBarSort(List<int> sortIndices);

  /// 保存默认首页索引
  Future<void> saveDefaultHomePageIndex(int index);

  /// 获取底部导航栏隐藏设置
  Future<bool> getHideBottomBar();

  /// 获取底部导航栏隐藏类型
  Future<BarHideType> getBarHideType();

  /// 获取平板导航优化设置
  Future<bool> getOptTabletNav();
}
