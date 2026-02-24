import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:PiliPlus/features/dynamics/domain/entities/follow_up.dart';
import 'package:PiliPlus/features/dynamics/presentation/providers/dynamics_providers.dart';

/// Controller for follow-up UP users.
class FollowUpController extends AsyncNotifier<FollowUpEntity> {
  @override
  Future<FollowUpEntity> build() {
    return fetchFollowUpInternal();
  }

  /// Fetch follow-up UP users.
  Future<FollowUpEntity> fetchFollowUpInternal() async {
    final useCase = ref.read(fetchFollowUpUseCaseProvider);
    final result = await useCase.call();

    if (result.isSuccess) {
      return result.data;
    } else {
      throw Exception('Failed to fetch follow-up data');
    }
  }

  /// Check if the user is logged in.
  bool get isLogin => true; // TODO: Get from account service

  /// Load more UP users.
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.offset == null) {
      return;
    }

    final useCase = ref.read(fetchFollowUpUseCaseProvider);
    final result = await useCase.call(offset: currentState.offset);

    if (result.isSuccess) {
      final newData = result.data;
      final currentList = currentState.upList;
      state = AsyncValue.data(
        FollowUpEntity(
          liveUsers: newData.liveUsers,
          upList: [...currentList, ...newData.upList],
          hasMore: newData.hasMore,
          offset: newData.offset,
        ),
      );
    }
    // Keep current state on error
  }

  /// Refresh follow-up data.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(fetchFollowUpInternal);
  }
}

/// Follow-up controller provider.
final followUpControllerProvider =
    AsyncNotifierProvider<FollowUpController, FollowUpEntity>(
  FollowUpController.new,
);
