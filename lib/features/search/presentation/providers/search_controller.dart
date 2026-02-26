import 'dart:async';

import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/search/domain/repositories/search_repository.dart';
import 'package:PiliPlus/features/search/presentation/providers/search_providers.dart'
    show searchRepositoryProvider;
import 'package:PiliPlus/features/search/presentation/providers/search_state.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_transform/stream_transform.dart';

/// 搜索控制器
///
/// 管理搜索功能的状态和逻辑
class SearchController extends Notifier<SearchState> {
  late final SearchRepository _repository;

  // 防抖流控制器
  StreamController<String>? _debounceController;
  StreamSubscription<String>? _debounceSubscription;
  static const Duration _debounceDuration = Duration(milliseconds: 200);

  @override
  SearchState build() {
    _repository = ref.watch(searchRepositoryProvider);

    // 初始化搜索历史
    final history = _repository.getSearchHistory();

    // 加载热搜和推荐
    _loadInitialData();

    return SearchState(
      history: history,
      enableSuggestion: Pref.searchSuggestion,
      enableTrending: Pref.enableTrending,
      enableRecommend: Pref.enableSearchRcmd,
      recordHistory: Pref.recordSearchHistory,
    );
  }

  /// 加载初始数据
  void _loadInitialData() {
    if (state.enableTrending) {
      queryTrendingList();
    }
    if (state.enableRecommend) {
      queryRecommendList();
    }
  }

  /// 验证是否显示UID按钮
  void validateUid(String text) {
    final showUidBtn = IdUtils.digitOnlyRegExp.hasMatch(text);
    state = state.copyWith(showUidBtn: showUidBtn);
  }

  /// 处理搜索文本变化
  void onTextChanged(String value) {
    validateUid(value);

    if (!state.enableSuggestion) {
      return;
    }

    if (value.isEmpty) {
      state = state.copyWith(suggestList: []);
      return;
    }

    // 使用防抖处理搜索建议
    _debounceController ??= StreamController<String>();
    _debounceSubscription?.cancel();
    _debounceSubscription = _debounceController!.stream
        .debounce(_debounceDuration, trailing: true)
        .listen((term) => _fetchSearchSuggest(term));
    _debounceController!.add(value);
  }

  /// 获取搜索建议
  Future<void> _fetchSearchSuggest(String term) async {
    try {
      final suggestList = await _repository.getSearchSuggest(term: term);
      state = state.copyWith(suggestList: suggestList);
    } catch (e) {
      state = state.copyWith(suggestList: []);
    }
  }

  /// 获取热搜榜
  Future<void> queryTrendingList({int limit = 10}) async {
    state = state.copyWith(
      trendingState: LoadingState.loading(),
    );

    try {
      final trendingData = await _repository.getSearchTrending(limit: limit);
      state = state.copyWith(
        trendingState: Success(trendingData),
      );
    } catch (e) {
      state = state.copyWith(
        trendingState: Error(e.toString()),
      );
    }
  }

  /// 获取搜索推荐
  Future<void> queryRecommendList() async {
    state = state.copyWith(
      recommendState: LoadingState.loading(),
    );

    try {
      final recommendList = await _repository.getSearchRecommend();
      state = state.copyWith(
        recommendState: Success(recommendList),
      );
    } catch (e) {
      state = state.copyWith(
        recommendState: Error(e.toString()),
      );
    }
  }

  /// 执行搜索
  Future<void> search({
    required SearchType searchType,
    required String keyword,
    int page = 1,
    String? order,
    int? duration,
    int? tids,
    int? orderSort,
    int? userType,
    int? categoryId,
    int? pubBegin,
    int? pubEnd,
    String? gaiaVtoken,
  }) async {
    // 添加搜索历史
    if (state.recordHistory && keyword.isNotEmpty) {
      _repository.addSearchHistory(keyword);
      state = state.copyWith(history: _repository.getSearchHistory());
    }

    state = state.copyWith(
      searchResultState: LoadingState.loading(),
    );

    try {
      final searchResults = await _repository.searchByType(
        searchType: searchType,
        keyword: keyword,
        page: page,
        order: order,
        duration: duration,
        tids: tids,
        orderSort: orderSort,
        userType: userType,
        categoryId: categoryId,
        pubBegin: pubBegin,
        pubEnd: pubEnd,
        gaiaVtoken: gaiaVtoken,
      );
      state = state.copyWith(
        searchResultState: Success(searchResults),
      );
    } catch (e) {
      state = state.copyWith(
        searchResultState: Error(e.toString()),
      );
    }
  }

  /// 清空搜索结果
  void clearSearchResult() {
    state = state.copyWith(
      searchResultState: null,
    );
  }

  /// 清空搜索建议
  void clearSuggest() {
    state = state.copyWith(suggestList: []);
  }

  /// 删除搜索历史
  void removeHistory(String keyword) {
    _repository.removeSearchHistory(keyword);
    state = state.copyWith(history: _repository.getSearchHistory());
  }

  /// 清空搜索历史
  void clearHistory() {
    _repository.clearSearchHistory();
    state = state.copyWith(history: _repository.getSearchHistory());
  }

  /// 点击关键词
  void onClickKeyword(String keyword) {
    clearSuggest();
    // 这里可以触发搜索，具体实现由调用方处理
  }
}
