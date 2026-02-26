/// 搜索热搜关键词实体
///
/// 包含热搜关键词信息
class SearchTrendingEntity {
  /// 关键词
  final String? keyword;

  /// 显示名称
  final String? showName;

  /// 图标
  final String? icon;

  /// 是否显示直播图标
  final bool? showLiveIcon;

  /// 推荐理由
  final String? recommendReason;

  const SearchTrendingEntity({
    this.keyword,
    this.showName,
    this.icon,
    this.showLiveIcon,
    this.recommendReason,
  });

  SearchTrendingEntity copyWith({
    String? keyword,
    String? showName,
    String? icon,
    bool? showLiveIcon,
    String? recommendReason,
  }) {
    return SearchTrendingEntity(
      keyword: keyword ?? this.keyword,
      showName: showName ?? this.showName,
      icon: icon ?? this.icon,
      showLiveIcon: showLiveIcon ?? this.showLiveIcon,
      recommendReason: recommendReason ?? this.recommendReason,
    );
  }

  /// 从模型创建实体
  factory SearchTrendingEntity.fromModel(dynamic model) {
    return SearchTrendingEntity(
      keyword: model?.keyword as String?,
      showName: model?.showName as String?,
      icon: model?.icon as String?,
      showLiveIcon: model?.showLiveIcon as bool?,
      recommendReason: model?.recommendReason as String?,
    );
  }
}

/// 搜索热搜数据实体
///
/// 包含热搜列表和置顶列表
class SearchTrendingDataEntity {
  /// 热搜列表
  final List<SearchTrendingEntity>? list;

  /// 置顶热搜列表
  final List<SearchTrendingEntity>? topList;

  const SearchTrendingDataEntity({
    this.list,
    this.topList,
  });

  SearchTrendingDataEntity copyWith({
    List<SearchTrendingEntity>? list,
    List<SearchTrendingEntity>? topList,
  }) {
    return SearchTrendingDataEntity(
      list: list ?? this.list,
      topList: topList ?? this.topList,
    );
  }
}
