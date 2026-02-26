import 'package:PiliPlus/features/search/domain/entities/search_history_entity.dart';
import 'package:PiliPlus/features/search/domain/entities/search_result_entity.dart';
import 'package:PiliPlus/features/search/domain/entities/search_suggest_entity.dart';
import 'package:PiliPlus/features/search/domain/entities/search_trending_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 搜索状态
///
/// 管理搜索功能的所有状态
class SearchState {
  /// 搜索历史
  final SearchHistoryEntity history;

  /// 搜索建议状态
  final LoadingState<List<SearchSuggestEntity>>? suggestState;

  /// 搜索建议列表
  final List<SearchSuggestEntity> suggestList;

  /// 热搜榜状态
  final LoadingState<SearchTrendingDataEntity>? trendingState;

  /// 搜索推荐状态
  final LoadingState<List<SearchTrendingEntity>>? recommendState;

  /// 搜索结果状态
  final LoadingState<List<SearchResultEntity>>? searchResultState;

  /// 是否启用搜索建议
  final bool enableSuggestion;

  /// 是否启用热搜
  final bool enableTrending;

  /// 是否启用搜索推荐
  final bool enableRecommend;

  /// 是否记录搜索历史
  final bool recordHistory;

  /// 是否显示UID按钮
  final bool showUidBtn;

  const SearchState({
    this.history = const SearchHistoryEntity(),
    this.suggestState,
    this.suggestList = const [],
    this.trendingState,
    this.recommendState,
    this.searchResultState,
    this.enableSuggestion = true,
    this.enableTrending = true,
    this.enableRecommend = true,
    this.recordHistory = true,
    this.showUidBtn = false,
  });

  SearchState copyWith({
    SearchHistoryEntity? history,
    LoadingState<List<SearchSuggestEntity>>? suggestState,
    List<SearchSuggestEntity>? suggestList,
    LoadingState<SearchTrendingDataEntity>? trendingState,
    LoadingState<List<SearchTrendingEntity>>? recommendState,
    LoadingState<List<SearchResultEntity>>? searchResultState,
    bool? enableSuggestion,
    bool? enableTrending,
    bool? enableRecommend,
    bool? recordHistory,
    bool? showUidBtn,
  }) {
    return SearchState(
      history: history ?? this.history,
      suggestState: suggestState,
      suggestList: suggestList ?? this.suggestList,
      trendingState: trendingState,
      recommendState: recommendState,
      searchResultState: searchResultState,
      enableSuggestion: enableSuggestion ?? this.enableSuggestion,
      enableTrending: enableTrending ?? this.enableTrending,
      enableRecommend: enableRecommend ?? this.enableRecommend,
      recordHistory: recordHistory ?? this.recordHistory,
      showUidBtn: showUidBtn ?? this.showUidBtn,
    );
  }

  /// 是否正在加载热搜
  bool get isTrendingLoading =>
      trendingState is Loading;

  /// 是否正在加载推荐
  bool get isRecommendLoading =>
      recommendState is Loading;

  /// 是否正在搜索
  bool get isSearching =>
      searchResultState is Loading;

  /// 热搜数据
  SearchTrendingDataEntity? get trendingData =>
      trendingState is Success
          ? (trendingState as Success<SearchTrendingDataEntity>).response
          : null;

  /// 推荐数据
  List<SearchTrendingEntity>? get recommendList =>
      recommendState is Success
          ? (recommendState as Success<List<SearchTrendingEntity>>).response
          : null;

  /// 搜索结果
  List<SearchResultEntity>? get searchResults =>
      searchResultState is Success
          ? (searchResultState as Success<List<SearchResultEntity>>).response
          : null;
}
