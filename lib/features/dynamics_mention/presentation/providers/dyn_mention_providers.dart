import 'package:PiliPlus/features/dynamics_mention/data/datasources/dyn_mention_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_mention/data/repositories/dyn_mention_repository_impl.dart';
import 'package:PiliPlus/features/dynamics_mention/domain/repositories/dyn_mention_repository.dart';
import 'package:PiliPlus/features/dynamics_mention/domain/usecases/search_mentions.dart';
import 'package:PiliPlus/features/dynamics_mention/presentation/providers/dyn_mention_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the dynamic mention remote data source
final dynMentionRemoteDatasourceProvider =
    Provider<DynMentionRemoteDatasource>((ref) {
  return DynMentionRemoteDatasource();
});

/// Provider for the dynamic mention repository
final dynMentionRepositoryProvider = Provider<DynMentionRepository>((ref) {
  final remoteDatasource = ref.watch(dynMentionRemoteDatasourceProvider);
  return DynMentionRepositoryImpl(remoteDatasource: remoteDatasource);
});

/// Provider for the search mentions use case
final searchMentionsProvider = Provider<SearchMentions>((ref) {
  final repository = ref.watch(dynMentionRepositoryProvider);
  return SearchMentions(repository);
});

/// Provider for the dynamic mention controller
final dynMentionControllerProvider =
    Provider<DynMentionController>((ref) {
  final searchMentions = ref.watch(searchMentionsProvider);
  final controller = DynMentionController(searchMentions);

  // Search on initialization
  controller.searchMentions();

  return controller;
});
