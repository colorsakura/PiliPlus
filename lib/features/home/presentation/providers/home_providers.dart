import 'package:PiliPlus/features/home/data/datasources/home_tab_local_datasource.dart';
import 'package:PiliPlus/features/home/data/datasources/search_remote_datasource.dart';
import 'package:PiliPlus/features/home/data/repositories/home_tab_repository_impl.dart';
import 'package:PiliPlus/features/home/data/repositories/search_repository_impl.dart';
import 'package:PiliPlus/features/home/domain/usecases/fetch_search_suggestion.dart';
import 'package:PiliPlus/features/home/domain/usecases/get_home_tab_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ========== Data Sources ==========

/// 首页标签本地数据源 Provider
final homeTabLocalDataSourceProvider = Provider<HomeTabLocalDataSource>((ref) {
  return HomeTabLocalDataSource();
});

/// 搜索建议远程数据源 Provider
final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  return SearchRemoteDataSource();
});

// ========== Repositories ==========

/// 首页标签仓库 Provider
final homeTabRepositoryProvider = Provider<HomeTabRepositoryImpl>((ref) {
  return HomeTabRepositoryImpl(
    localDataSource: ref.read(homeTabLocalDataSourceProvider),
  );
});

/// 搜索建议仓库 Provider
final searchRepositoryProvider = Provider<SearchRepositoryImpl>((ref) {
  return SearchRepositoryImpl(
    remoteDataSource: ref.read(searchRemoteDataSourceProvider),
  );
});

// ========== Use Cases ==========

/// 获取首页标签配置用例 Provider
final getHomeTabConfigUseCaseProvider = Provider<GetHomeTabConfigUseCase>((
  ref,
) {
  return GetHomeTabConfigUseCase(
    ref.read(homeTabRepositoryProvider),
  );
});

/// 获取搜索建议用例 Provider
final fetchSearchSuggestionUseCaseProvider =
    Provider<FetchSearchSuggestionUseCase>((ref) {
      return FetchSearchSuggestionUseCase(
        ref.read(searchRepositoryProvider),
      );
    });
