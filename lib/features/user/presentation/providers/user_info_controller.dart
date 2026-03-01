import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/user/domain/usecases/fetch_user_info.dart';
import 'package:PiliPlus/features/user/domain/repositories/user_repository.dart';
import 'package:PiliPlus/features/user/domain/entities/user_params.dart';
import 'package:PiliPlus/features/user/data/datasources/user_remote_datasource.dart';
import 'package:PiliPlus/features/user/data/datasources/user_remote_datasource_impl.dart';
import 'package:PiliPlus/features/user/data/datasources/user_remote_datasource_interface.dart';
import 'package:PiliPlus/features/user/data/repositories/user_repository_impl.dart';
import 'package:PiliPlus/models/user/info.dart';

part 'user_info_controller.g.dart';

/// Provider for UserRemoteDataSource
final userRemoteDataSourceProvider = Provider<IUserRemoteDataSource>((ref) {
  final baseDataSource = UserRemoteDataSource();
  return UserRemoteDataSourceImpl(baseDataSource);
});

/// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final datasource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource: datasource);
});

/// Provider for FetchUserInfo use case
final fetchUserInfoProvider = Provider<FetchUserInfo>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return FetchUserInfo(repository);
});

/// User info state
class UserInfoState {
  final UserInfoData? userInfo;
  final bool isLoading;
  final String? errorMessage;

  const UserInfoState({
    this.userInfo,
    this.isLoading = false,
    this.errorMessage,
  });

  UserInfoState copyWith({
    UserInfoData? userInfo,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserInfoState(
      userInfo: userInfo ?? this.userInfo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for managing user information
@riverpod
class UserInfoController extends _$UserInfoController {
  @override
  UserInfoState build() {
    return const UserInfoState();
  }

  /// Fetch user navigation information
  Future<void> fetchUserInfo({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final fetchUserInfo = ref.read(fetchUserInfoProvider);
      final userInfo = await fetchUserInfo(
        FetchUserInfoParams(forceRefresh: forceRefresh),
      );

      state = state.copyWith(
        userInfo: userInfo,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear user info
  void clearUserInfo() {
    state = const UserInfoState();
  }
}
