import 'package:PiliPlus/models/common/home_tab_type.dart';

/// 首页标签配置实体
///
/// 包含首页 Tab 的所有配置信息
class HomeTabConfig {
  /// 所有可用的标签类型
  final List<HomeTabType> tabs;

  /// 当前选中的标签索引
  final int selectedIndex;

  /// 是否隐藏顶部栏
  final bool hideTopBar;

  /// 是否启用搜索词建议
  final bool enableSearchWord;

  /// 默认搜索词
  final String defaultSearch;

  /// 上次检查搜索词的时间戳
  final int lastCheckSearchAt;

  const HomeTabConfig({
    required this.tabs,
    required this.selectedIndex,
    required this.hideTopBar,
    required this.enableSearchWord,
    this.defaultSearch = '',
    this.lastCheckSearchAt = 0,
  });

  /// 获取当前选中的标签
  HomeTabType get selectedTab => tabs.isNotEmpty && selectedIndex < tabs.length
      ? tabs[selectedIndex]
      : HomeTabType.rcmd;

  /// 是否有多于一个标签
  bool get hasMultipleTabs => tabs.length > 1;

  /// 是否包含特定标签
  bool containsTab(HomeTabType tab) => tabs.contains(tab);

  /// 获取推荐页的索引
  int get rcmdIndex => tabs.indexOf(HomeTabType.rcmd);

  HomeTabConfig copyWith({
    List<HomeTabType>? tabs,
    int? selectedIndex,
    bool? hideTopBar,
    bool? enableSearchWord,
    String? defaultSearch,
    int? lastCheckSearchAt,
  }) {
    return HomeTabConfig(
      tabs: tabs ?? this.tabs,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      hideTopBar: hideTopBar ?? this.hideTopBar,
      enableSearchWord: enableSearchWord ?? this.enableSearchWord,
      defaultSearch: defaultSearch ?? this.defaultSearch,
      lastCheckSearchAt: lastCheckSearchAt ?? this.lastCheckSearchAt,
    );
  }

  /// 创建默认配置
  factory HomeTabConfig.defaultConfig() {
    return HomeTabConfig(
      tabs: HomeTabType.values,
      selectedIndex: 0,
      hideTopBar: false,
      enableSearchWord: false,
      defaultSearch: '',
      lastCheckSearchAt: 0,
    );
  }
}
