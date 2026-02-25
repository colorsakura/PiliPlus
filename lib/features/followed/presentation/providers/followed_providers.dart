import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/followed/data/datasources/followed_remote_datasource.dart';
import 'package:PiliPlus/features/followed/data/repositories/followed_repository_impl.dart';
import 'package:PiliPlus/features/followed/domain/repositories/followed_repository.dart';
import 'package:PiliPlus/features/followed/domain/usecases/get_followed_list_usecase.dart';
import 'package:PiliPlus/features/followed/domain/usecases/get_user_name_usecase.dart';
import 'package:PiliPlus/features/followed/presentation/providers/followed_controller.dart';

/// Parameters for followed page
class FollowedParams {
  const FollowedParams({
    required this.mid,
    this.name,
  });

  final int mid;
  final String? name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowedParams &&
          runtimeType == other.runtimeType &&
          other.mid == mid &&
          other.name == name;

  @override
  int get hashCode => mid.hashCode ^ name.hashCode;
}

// Remote Datasource Provider
final followedRemoteDatasourceProvider = Provider<FollowedRemoteDatasource>((
  ref,
) {
  return const FollowedRemoteDatasource();
});

// Repository Provider
final followedRepositoryProvider = Provider<FollowedRepository>((ref) {
  final datasource = ref.watch(followedRemoteDatasourceProvider);
  return FollowedRepositoryImpl(datasource);
});

// Use Cases Providers
final getFollowedListUseCaseProvider = Provider<GetFollowedListUseCase>((ref) {
  final repository = ref.watch(followedRepositoryProvider);
  return GetFollowedListUseCase(repository);
});

final getUserNameUseCaseProvider = Provider<GetUserNameUseCase>((ref) {
  final repository = ref.watch(followedRepositoryProvider);
  return GetUserNameUseCase(repository);
});

// Controller Provider - uses Provider.family for parameterization
final followedControllerProvider =
    Provider.family<FollowedController, FollowedParams>((ref, params) {
      final getListUseCase = ref.watch(getFollowedListUseCaseProvider);
      final getUserNameUseCase = ref.watch(getUserNameUseCaseProvider);
      return FollowedController(
        getListUseCase: getListUseCase,
        getUserNameUseCase: getUserNameUseCase,
        mid: params.mid,
        name: params.name,
      );
    });
