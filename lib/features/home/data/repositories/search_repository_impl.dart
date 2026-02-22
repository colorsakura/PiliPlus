import 'package:PiliPlus/features/home/data/datasources/search_remote_datasource.dart';
import 'package:PiliPlus/features/home/domain/entities/search_suggestion.dart';
import 'package:PiliPlus/features/home/domain/repositories/search_repository.dart';

/// 搜索建议仓库实现
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;

  SearchRepositoryImpl({
    required SearchRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<SearchSuggestion?> getDefaultSearchSuggestion() =>
      _remoteDataSource.getDefaultSearchSuggestion();
}
