import 'package:PiliPlus/features/history_search/data/datasources/history_remote_datasource.dart';
import 'package:PiliPlus/features/history_search/data/repositories/history_search_repository_impl.dart';
import 'package:PiliPlus/features/history_search/domain/repositories/history_search_repository.dart';
import 'package:PiliPlus/features/history_search/domain/usecases/history_search_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// History remote data source provider
final historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>((ref) {
  return const HistoryRemoteDataSourceImpl();
});

/// History search repository provider
final historySearchRepositoryProvider = Provider<HistorySearchRepository>((ref) {
  final remoteDataSource = ref.watch(historyRemoteDataSourceProvider);
  return HistorySearchRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Search history use case provider
final searchHistoryUseCaseProvider = Provider<SearchHistory>((ref) {
  final repository = ref.watch(historySearchRepositoryProvider);
  return SearchHistory(repository);
});

/// Delete history item use case provider
final deleteHistoryItemUseCaseProvider = Provider<DeleteHistoryItem>((ref) {
  final repository = ref.watch(historySearchRepositoryProvider);
  return DeleteHistoryItem(repository);
});

/// Delete multiple history items use case provider
final deleteMultipleHistoryItemsUseCaseProvider = Provider<DeleteMultipleHistoryItems>((ref) {
  final repository = ref.watch(historySearchRepositoryProvider);
  return DeleteMultipleHistoryItems(repository);
});
