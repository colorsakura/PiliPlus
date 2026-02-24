import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/search_trending/domain/entities/search_trending_item.dart';

/// Search trending state
class SearchTrendingState {
  final LoadingState<List<SearchTrendingItemEntity>> items;
  final int topCount;

  const SearchTrendingState({
    required this.items,
    this.topCount = 0,
  });

  SearchTrendingState copyWith({
    LoadingState<List<SearchTrendingItemEntity>>? items,
    int? topCount,
  }) {
    return SearchTrendingState(
      items: items ?? this.items,
      topCount: topCount ?? this.topCount,
    );
  }
}
