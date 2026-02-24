import 'package:PiliPlus/models/search/search_trending/list.dart';

/// Search trending item entity
class SearchTrendingItemEntity {
  final String? keyword;
  final String? icon;
  final bool? showLiveIcon;

  const SearchTrendingItemEntity({
    this.keyword,
    this.icon,
    this.showLiveIcon,
  });

  /// Convert from model
  factory SearchTrendingItemEntity.fromModel(SearchTrendingItemModel model) {
    return SearchTrendingItemEntity(
      keyword: model.keyword,
      icon: model.icon,
      showLiveIcon: model.showLiveIcon,
    );
  }
}
