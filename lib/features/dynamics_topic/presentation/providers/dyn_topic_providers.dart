import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/dynamics_topic/data/datasources/dyn_topic_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_topic/data/repositories/dyn_topic_repository_impl.dart';
import 'package:PiliPlus/features/dynamics_topic/domain/repositories/dyn_topic_repository.dart';
import 'package:PiliPlus/features/dynamics_topic/domain/usecases/get_dyn_topic_data.dart';
import 'package:PiliPlus/features/dynamics_topic/presentation/providers/dyn_topic_controller.dart';
import 'package:PiliPlus/utils/accounts.dart';

/// Dynamics topic remote data source provider
final dynTopicRemoteDataSourceProvider = Provider<DynTopicRemoteDataSource>((
  ref,
) {
  return DynTopicRemoteDataSource();
});

/// Dynamics topic repository provider
final dynTopicRepositoryProvider = Provider<DynTopicRepository>((ref) {
  final remoteDataSource = ref.watch(dynTopicRemoteDataSourceProvider);
  return DynTopicRepositoryImpl(remoteDataSource);
});

/// Get topic top use case provider
final getTopicTopUseCaseProvider = Provider<GetTopicTopUseCase>((ref) {
  final repository = ref.watch(dynTopicRepositoryProvider);
  return GetTopicTopUseCase(repository);
});

/// Get topic feed use case provider
final getTopicFeedUseCaseProvider = Provider<GetTopicFeedUseCase>((ref) {
  final repository = ref.watch(dynTopicRepositoryProvider);
  return GetTopicFeedUseCase(repository);
});

/// Add favorite topic use case provider
final addFavTopicUseCaseProvider = Provider<AddFavTopicUseCase>((ref) {
  final repository = ref.watch(dynTopicRepositoryProvider);
  return AddFavTopicUseCase(repository);
});

/// Delete favorite topic use case provider
final delFavTopicUseCaseProvider = Provider<DelFavTopicUseCase>((ref) {
  final repository = ref.watch(dynTopicRepositoryProvider);
  return DelFavTopicUseCase(repository);
});

/// Like topic use case provider
final likeTopicUseCaseProvider = Provider<LikeTopicUseCase>((ref) {
  final repository = ref.watch(dynTopicRepositoryProvider);
  return LikeTopicUseCase(repository);
});

/// Dynamics topic controller provider family
/// Uses topic ID as the key
final dynTopicControllerProvider =
    Provider.family<DynTopicController, ({String id, String name})>((
      ref,
      params,
    ) {
      return DynTopicController(
        getTopicTopUseCase: ref.read(getTopicTopUseCaseProvider),
        getTopicFeedUseCase: ref.read(getTopicFeedUseCaseProvider),
        addFavTopicUseCase: ref.read(addFavTopicUseCaseProvider),
        delFavTopicUseCase: ref.read(delFavTopicUseCaseProvider),
        likeTopicUseCase: ref.read(likeTopicUseCaseProvider),
        topicId: params.id,
        topicName: params.name,
        isLogin: Accounts.main.isLogin,
      );
    });
