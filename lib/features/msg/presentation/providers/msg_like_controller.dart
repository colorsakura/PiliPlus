import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/msg/domain/usecases/get_like_messages.dart';
import 'package:PiliPlus/features/msg/presentation/providers/msg_unread_controller.dart';
import 'package:PiliPlus/models/msg/msg_like/item.dart';
import 'package:PiliPlus/models/msg/msg_like/cursor.dart';
import 'package:PiliPlus/http/loading_state.dart';

part 'msg_like_controller.g.dart';

/// Provider for GetLikeMessages use case
final getLikeMessagesProvider = Provider<GetLikeMessages>((ref) {
  final repository = ref.watch(msgRepositoryProvider);
  return GetLikeMessages(repository);
});

/// Like messages state
class MsgLikeState {
  final List<MsgLikeItem>? items;
  final Cursor? cursor;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;

  const MsgLikeState({
    this.items,
    this.cursor,
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
  });

  MsgLikeState copyWith({
    List<MsgLikeItem>? items,
    Cursor? cursor,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
  }) {
    return MsgLikeState(
      items: items ?? this.items,
      cursor: cursor ?? this.cursor,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Controller for managing like messages
@riverpod
class MsgLikeController extends _$MsgLikeController {
  @override
  MsgLikeState build() {
    return const MsgLikeState();
  }

  /// Fetch like messages
  Future<void> fetchLikeMessages({
    int? cursor,
    int? cursorTime,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = const MsgLikeState();
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final getLike = ref.read(getLikeMessagesProvider);
      final result = await getLike(
        cursor: cursor,
        cursorTime: cursorTime,
      );

      switch (result) {
        case Success(:final response):
          // Use total items for like messages
          final newItems = response.total?.items ?? [];
          final existingItems = refresh ? [] : (state.items ?? []);

          state = state.copyWith(
            items: [...existingItems, ...newItems],
            cursor: response.total?.cursor,
            isLoading: false,
            hasMore: response.total?.cursor?.isEnd == false,
          );
        case Error(:final errMsg):
          state = state.copyWith(
            isLoading: false,
            errorMessage: errMsg,
          );
        case Loading():
          // Still loading
          break;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more messages
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    await fetchLikeMessages(
      cursor: state.cursor?.id,
      cursorTime: state.cursor?.time,
    );
  }

  /// Refresh messages
  Future<void> refresh() async {
    await fetchLikeMessages(refresh: true);
  }

  /// Clear messages
  void clearMessages() {
    state = const MsgLikeState();
  }
}
