import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/search/data/datasources/search_remote_datasource.dart';
import 'package:PiliPlus/features/search/data/repositories/search_repository_impl.dart';
import 'package:PiliPlus/features/search/domain/repositories/search_repository.dart';
import 'package:PiliPlus/features/search/domain/usecases/get_search_recommend.dart';
import 'package:PiliPlus/features/search/domain/usecases/get_search_suggest.dart';
import 'package:PiliPlus/features/search/domain/usecases/get_search_trending.dart';
import 'package:PiliPlus/features/search/domain/usecases/manage_search_history.dart';
import 'package:PiliPlus/features/search/domain/usecases/search_by_type.dart';
import 'package:PiliPlus/features/search/presentation/providers/search_controller.dart';
import 'package:PiliPlus/features/search/presentation/providers/search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 搜索远程数据源Provider
final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  return SearchRemoteDataSource();
});

/// 搜索仓库Provider
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final dataSource = ref.watch(searchRemoteDataSourceProvider);
  return SearchRepositoryImpl(
    remoteDataSource: dataSource,
  );
});

/// 获取搜索建议用例Provider
final getSearchSuggestUseCaseProvider = Provider<GetSearchSuggestUseCase>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return GetSearchSuggestUseCase(repository);
});

/// 分类搜索用例Provider
final searchByTypeUseCaseProvider = Provider<SearchByTypeUseCase>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchByTypeUseCase(repository);
});

/// 获取热搜榜用例Provider
final getSearchTrendingUseCaseProvider = Provider<GetSearchTrendingUseCase>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return GetSearchTrendingUseCase(repository);
});

/// 获取搜索推荐用例Provider
final getSearchRecommendUseCaseProvider = Provider<GetSearchRecommendUseCase>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return GetSearchRecommendUseCase(repository);
});

/// 管理搜索历史用例Provider
final manageSearchHistoryUseCaseProvider = Provider<ManageSearchHistoryUseCase>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return ManageSearchHistoryUseCase(repository);
});

/// 搜索状态Provider
final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);

/// 搜索建议开关Provider
final searchSuggestionEnabledProvider = Provider<bool>((ref) {
  return Pref.searchSuggestion;
});

/// 热搜开关Provider
final trendingEnabledProvider = Provider<bool>((ref) {
  return Pref.enableTrending;
});

/// 搜索推荐开关Provider
final searchRcmdEnabledProvider = Provider<bool>((ref) {
  return Pref.enableSearchRcmd;
});

/// 记录搜索历史开关Provider
final recordSearchHistoryProvider = Provider<bool>((ref) {
  return Pref.recordSearchHistory;
});
