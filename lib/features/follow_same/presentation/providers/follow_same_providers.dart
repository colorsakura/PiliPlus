import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/follow_same/data/datasources/follow_same_remote_datasource.dart';
import 'package:PiliPlus/features/follow_same/data/repositories/follow_same_repository_impl.dart';
import 'package:PiliPlus/features/follow_same/domain/repositories/follow_same_repository.dart';
import 'package:PiliPlus/features/follow_same/domain/usecases/get_same_follow_list_usecase.dart';
import 'package:PiliPlus/features/follow_same/domain/usecases/get_same_user_name_usecase.dart';
import 'package:PiliPlus/features/follow_same/presentation/providers/follow_same_controller.dart';

/// Parameters for follow_same page
class FollowSameParams {
  const FollowSameParams({
    required this.mid,
    this.name,
  });

  final int mid;
  final String? name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowSameParams &&
          runtimeType == other.runtimeType &&
          other.mid == mid &&
          other.name == name;

  @override
  int get hashCode => mid.hashCode ^ name.hashCode;
}

// Remote Datasource Provider
final followSameRemoteDatasourceProvider =
    Provider<FollowSameRemoteDatasource>((ref) {
  return const FollowSameRemoteDatasource();
});

// Repository Provider
final followSameRepositoryProvider = Provider<FollowSameRepository>((ref) {
  final datasource = ref.watch(followSameRemoteDatasourceProvider);
  return FollowSameRepositoryImpl(datasource);
});

// Use Cases Providers
final getSameFollowListUseCaseProvider = Provider<GetSameFollowListUseCase>((ref) {
  final repository = ref.watch(followSameRepositoryProvider);
  return GetSameFollowListUseCase(repository);
});

final getSameUserNameUseCaseProvider = Provider<GetSameUserNameUseCase>((ref) {
  final repository = ref.watch(followSameRepositoryProvider);
  return GetSameUserNameUseCase(repository);
});

// Controller Provider - uses Provider.family for parameterization
final followSameControllerProvider =
    Provider.family<FollowSameController, FollowSameParams>((ref, params) {
  final getListUseCase = ref.watch(getSameFollowListUseCaseProvider);
  final getUserNameUseCase = ref.watch(getSameUserNameUseCaseProvider);
  return FollowSameController(
    getListUseCase: getListUseCase,
    getUserNameUseCase: getUserNameUseCase,
    mid: params.mid,
    name: params.name,
  );
});
