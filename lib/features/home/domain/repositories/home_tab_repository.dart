import 'package:PiliPlus/features/home/domain/entities/home_tab_config.dart';

/// 首页标签配置仓库接口
abstract interface class HomeTabRepository {
  /// 获取首页标签配置
  Future<HomeTabConfig> getHomeTabConfig();

  /// 保存标签排序
  Future<void> saveTabSort(List<int> sortIndices);

  /// 获取是否隐藏顶部栏
  Future<bool> getHideTopBar();

  /// 获取是否启用搜索词建议
  Future<bool> getEnableSearchWord();
}
