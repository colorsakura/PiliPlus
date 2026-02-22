import 'package:PiliPlus/features/home/data/datasources/home_tab_local_datasource.dart';
import 'package:PiliPlus/features/home/domain/entities/home_tab_config.dart';
import 'package:PiliPlus/features/home/domain/repositories/home_tab_repository.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';

/// 首页标签配置仓库实现
class HomeTabRepositoryImpl implements HomeTabRepository {
  final HomeTabLocalDataSource _localDataSource;

  HomeTabRepositoryImpl({
    required HomeTabLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<HomeTabConfig> getHomeTabConfig() async {
    final tabs = _localDataSource.getTabSort();
    final hideTopBar = _localDataSource.getHideTopBar();
    final enableSearchWord = _localDataSource.getEnableSearchWord();

    // 找到推荐页的索引作为默认选中项
    final rcmdIndex = tabs.indexOf(HomeTabType.rcmd);
    final selectedIndex = rcmdIndex >= 0 ? rcmdIndex : 0;

    return HomeTabConfig(
      tabs: tabs,
      selectedIndex: selectedIndex,
      hideTopBar: hideTopBar,
      enableSearchWord: enableSearchWord,
      defaultSearch: '',
      lastCheckSearchAt: 0,
    );
  }

  @override
  Future<void> saveTabSort(List<int> sortIndices) async {
    await _localDataSource.saveTabSort(sortIndices);
  }

  @override
  Future<bool> getHideTopBar() async {
    return _localDataSource.getHideTopBar();
  }

  @override
  Future<bool> getEnableSearchWord() async {
    return _localDataSource.getEnableSearchWord();
  }
}
