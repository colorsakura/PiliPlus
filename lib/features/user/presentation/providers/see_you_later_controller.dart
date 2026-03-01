import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/user/domain/usecases/fetch_see_you_later.dart';
import 'package:PiliPlus/features/user/domain/entities/user_params.dart';
import 'package:PiliPlus/features/user/presentation/providers/user_info_controller.dart';
import 'package:PiliPlus/models/later/data.dart';

part 'see_you_later_controller.g.dart';

/// Provider for FetchSeeYouLater use case
final fetchSeeYouLaterProvider = Provider<FetchSeeYouLater>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return FetchSeeYouLater(repository);
});

/// See You Later state
class SeeYouLaterState {
  final LaterData? laterData;
  final bool isLoading;
  final String? errorMessage;

  const SeeYouLaterState({
    this.laterData,
    this.isLoading = false,
    this.errorMessage,
  });

  SeeYouLaterState copyWith({
    LaterData? laterData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SeeYouLaterState(
      laterData: laterData ?? this.laterData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for managing "See You Later" (watch later) list
@riverpod
class SeeYouLaterController extends _$SeeYouLaterController {
  @override
  SeeYouLaterState build() {
    return const SeeYouLaterState();
  }

  /// Fetch "See You Later" list
  Future<void> fetchSeeYouLater({
    required int page,
    int viewed = 0,
    String keyword = '',
    bool asc = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final fetchSeeYouLater = ref.read(fetchSeeYouLaterProvider);
      final laterData = await fetchSeeYouLater(
        FetchSeeYouLaterParams(
          page: page,
          viewed: viewed,
          keyword: keyword,
          asc: asc,
        ),
      );

      state = state.copyWith(
        laterData: laterData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear See You Later data
  void clearSeeYouLater() {
    state = const SeeYouLaterState();
  }
}
