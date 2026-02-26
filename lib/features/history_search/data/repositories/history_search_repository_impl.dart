import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/history_search/data/datasources/history_remote_datasource.dart';
import 'package:PiliPlus/features/history_search/domain/entities/history_search.dart';
import 'package:PiliPlus/features/history_search/domain/repositories/history_search_repository.dart';

/// History search repository implementation
class HistorySearchRepositoryImpl implements HistorySearchRepository {
  final HistoryRemoteDataSource remoteDataSource;

  const HistorySearchRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<HistorySearchResultEntity>> searchHistory(
    HistorySearchParamsEntity params,
  ) async {
    final result = await remoteDataSource.searchHistory(
      pn: params.page,
      keyword: params.keyword,
      account: null, // Will use default account
    );

    if (result case Success(:final data)) {
      final items = data.list ?? [];
      // Check if there are more results based on cursor.max
      final hasMore = data.cursor?.max != null && items.isNotEmpty;

      return Success(
        HistorySearchResultEntity(
          historyItems: items,
          hasMore: hasMore,
        ),
      );
    } else {
      return result as Error;
    }
  }

  @override
  Future<LoadingState<void>> deleteHistory(HistoryDeleteParamsEntity params) async {
    return await remoteDataSource.deleteHistory(
      historyKey: params.historyKey,
      account: null, // Will use default account
    );
  }

  @override
  Future<LoadingState<void>> deleteMultipleHistory(
    List<String> historyKeys,
    String account,
  ) async {
    // Delete all in batch by joining keys with comma
    return await remoteDataSource.deleteHistory(
      historyKey: historyKeys.join(','),
      account: null, // Will use default account
    );
  }
}
