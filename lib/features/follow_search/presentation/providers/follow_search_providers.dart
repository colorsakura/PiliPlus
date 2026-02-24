import 'package:PiliPlus/features/follow_search/data/datasources/follow_search_remote_datasource.dart';
import 'package:PiliPlus/features/follow_search/data/repositories/follow_search_repository_impl.dart';
import 'package:PiliPlus/features/follow_search/domain/repositories/follow_search_repository.dart';
import 'package:PiliPlus/features/follow_search/domain/usecases/search_follows_usecase.dart';
import 'package:PiliPlus/features/follow_search/presentation/providers/follow_search_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Remote datasource provider
final followSearchRemoteDatasourceProvider =
    Provider<FollowSearchRemoteDatasource>((ref) {
  return const FollowSearchRemoteDatasource();
});

/// Repository provider
final followSearchRepositoryProvider = Provider<FollowSearchRepository>((ref) {
  final datasource = ref.watch(followSearchRemoteDatasourceProvider);
  return FollowSearchRepositoryImpl(datasource);
});

/// Search follows use case provider
final searchFollowsUseCaseProvider = Provider<SearchFollowsUseCase>((ref) {
  final repository = ref.watch(followSearchRepositoryProvider);
  return SearchFollowsUseCase(repository);
});

/// Follow search controller provider (family for different mid values)
final followSearchControllerProvider =
    Provider.family<FollowSearchController, int>((ref, mid) {
  return FollowSearchController(
    mid: mid,
    searchFollowsUseCase: ref.watch(searchFollowsUseCaseProvider),
  );
});
