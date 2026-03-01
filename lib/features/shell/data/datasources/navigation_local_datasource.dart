import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/models/common/bar_hide_type.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';

/// 导航配置本地数据源
class NavigationLocalDataSource {
  /// 获取导航栏排序配置
  List<NavigationBarType> getNavBarSort() {
    final List<int>? navBarSort =
        GStorage.settingRepository.getStringList(SettingBoxKey.navBarSort)?.map(int.parse).toList();

    if (navBarSort == null || navBarSort.isEmpty) {
      return NavigationBarType.values;
    }

    return navBarSort.map((i) => NavigationBarType.values[i]).toList();
  }

  /// 保存导航栏排序
  Future<void> saveNavBarSort(List<int> sortIndices) async {
    await GStorage.settingRepository.setStringList(
      SettingBoxKey.navBarSort,
      sortIndices.map((e) => e.toString()).toList(),
    );
  }

  /// 获取默认首页索引
  int getDefaultHomePageIndex() {
    return Pref.defaultHomePageIndex;
  }

  /// 保存默认首页索引
  Future<void> saveDefaultHomePageIndex(int index) async {
    // 注意：Pref.defaultHomePageIndex 是只读的
    // 如果需要保存，需要直接操作 GStorage
    // await GStorage.setting.put(SettingBoxKey.defaultHomePageIndex, index);
  }

  /// 获取底部导航栏隐藏设置
  bool getHideBottomBar() {
    return Pref.hideBottomBar;
  }

  /// 获取底部导航栏隐藏类型
  BarHideType getBarHideType() {
    return Pref.barHideType;
  }

  /// 获取平板导航优化设置
  bool getOptTabletNav() {
    return Pref.optTabletNav;
  }

  /// 获取导航栏配置总数
  int getNavigationBarsCount() {
    return getNavBarSort().length;
  }
}
