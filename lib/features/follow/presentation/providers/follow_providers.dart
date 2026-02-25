import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/follow/data/datasources/follow_remote_datasource.dart';
import 'package:PiliPlus/features/follow/data/repositories/follow_repository_impl.dart';
import 'package:PiliPlus/features/follow/domain/repositories/follow_repository.dart';
import 'package:PiliPlus/features/follow/domain/usecases/get_member_card_info_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/get_follow_up_tags_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/create_follow_tag_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/update_follow_tag_usecase.dart';
import 'package:PiliPlus/features/follow/domain/usecases/delete_follow_tag_usecase.dart';
import 'package:PiliPlus/features/follow/presentation/providers/follow_controller.dart';

// Remote Datasource Provider
final followRemoteDatasourceProvider = Provider<FollowRemoteDatasource>((ref) {
  return const FollowRemoteDatasource();
});

// Repository Provider
final followRepositoryProvider = Provider<FollowRepository>((ref) {
  final datasource = ref.watch(followRemoteDatasourceProvider);
  return FollowRepositoryImpl(datasource);
});

// Use Case Providers
final getMemberCardInfoUseCaseProvider = Provider<GetMemberCardInfoUseCase>((
  ref,
) {
  final repository = ref.watch(followRepositoryProvider);
  return GetMemberCardInfoUseCase(repository);
});

final getFollowUpTagsUseCaseProvider = Provider<GetFollowUpTagsUseCase>((ref) {
  final repository = ref.watch(followRepositoryProvider);
  return GetFollowUpTagsUseCase(repository);
});

final createFollowTagUseCaseProvider = Provider<CreateFollowTagUseCase>((ref) {
  final repository = ref.watch(followRepositoryProvider);
  return CreateFollowTagUseCase(repository);
});

final updateFollowTagUseCaseProvider = Provider<UpdateFollowTagUseCase>((ref) {
  final repository = ref.watch(followRepositoryProvider);
  return UpdateFollowTagUseCase(repository);
});

final deleteFollowTagUseCaseProvider = Provider<DeleteFollowTagUseCase>((ref) {
  final repository = ref.watch(followRepositoryProvider);
  return DeleteFollowTagUseCase(repository);
});

// Controller Provider - uses Provider.family for different (mid, isOwner, userName) combinations
final followControllerProvider =
    Provider.family<FollowController, FollowParams>((ref, params) {
      return FollowController(
        mid: params.mid,
        isOwner: params.isOwner,
        userName: params.userName,
        getMemberCardInfoUseCase: ref.watch(getMemberCardInfoUseCaseProvider),
        getFollowUpTagsUseCase: ref.watch(getFollowUpTagsUseCaseProvider),
        createFollowTagUseCase: ref.watch(createFollowTagUseCaseProvider),
        updateFollowTagUseCase: ref.watch(updateFollowTagUseCaseProvider),
        deleteFollowTagUseCase: ref.watch(deleteFollowTagUseCaseProvider),
      );
    });

/// Parameters for FollowController
class FollowParams {
  const FollowParams({
    required this.mid,
    required this.isOwner,
    this.userName,
  });

  final int mid;
  final bool isOwner;
  final String? userName;
}
