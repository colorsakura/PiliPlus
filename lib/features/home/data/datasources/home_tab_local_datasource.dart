import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';

/// 首页标签配置本地数据源
class HomeTabLocalDataSource {
  /// 获取标签排序配置
  List<HomeTabType> getTabSort() {
    final List<int>? tabBarSort =
        GStorage.settingRepository.getStringList(SettingBoxKey.tabBarSort)?.map(int.parse).toList();

    if (tabBarSort == null || tabBarSort.isEmpty) {
      return HomeTabType.values;
    }

    return tabBarSort.map((i) => HomeTabType.values[i]).toList();
  }

  /// 保存标签排序
  Future<void> saveTabSort(List<int> sortIndices) async {
    await GStorage.settingRepository.setStringList(
      SettingBoxKey.tabBarSort,
      sortIndices.map((e) => e.toString()).toList(),
    );
  }

  /// 获取是否隐藏顶部栏
  bool getHideTopBar() {
    return Pref.hideTopBar;
  }

  /// 获取是否启用搜索词建议
  bool getEnableSearchWord() {
    return Pref.enableSearchWord;
  }
}
