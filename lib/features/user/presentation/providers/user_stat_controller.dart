import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/user/domain/usecases/fetch_user_stat.dart';
import 'package:PiliPlus/features/user/domain/entities/user_params.dart';
import 'package:PiliPlus/features/user/presentation/providers/user_info_controller.dart';
import 'package:PiliPlus/models/user/stat.dart';

part 'user_stat_controller.g.dart';

/// Provider for FetchUserStat use case
final fetchUserStatProvider = Provider<FetchUserStat>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return FetchUserStat(repository);
});

/// User stat state
class UserStatState {
  final UserStat? userStat;
  final bool isLoading;
  final String? errorMessage;

  const UserStatState({
    this.userStat,
    this.isLoading = false,
    this.errorMessage,
  });

  UserStatState copyWith({
    UserStat? userStat,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserStatState(
      userStat: userStat ?? this.userStat,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for managing user statistics
@riverpod
class UserStatController extends _$UserStatController {
  @override
  UserStatState build() {
    return const UserStatState();
  }

  /// Fetch user statistics
  Future<void> fetchUserStat({required bool isOwner}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final fetchUserStat = ref.read(fetchUserStatProvider);
      final userStat = await fetchUserStat(
        FetchUserStatParams(isOwner: isOwner),
      );

      state = state.copyWith(
        userStat: userStat,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear user stat
  void clearUserStat() {
    state = const UserStatState();
  }
}
