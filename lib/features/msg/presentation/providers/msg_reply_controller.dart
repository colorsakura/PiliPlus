import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/msg/domain/usecases/get_reply_messages.dart';
import 'package:PiliPlus/features/msg/presentation/providers/msg_unread_controller.dart';
import 'package:PiliPlus/models/msg/msg_reply/item.dart';
import 'package:PiliPlus/models/msg/msg_reply/cursor.dart';
import 'package:PiliPlus/http/loading_state.dart';

part 'msg_reply_controller.g.dart';

/// Provider for GetReplyMessages use case
final getReplyMessagesProvider = Provider<GetReplyMessages>((ref) {
  final repository = ref.watch(msgRepositoryProvider);
  return GetReplyMessages(repository);
});

/// Reply messages state
class MsgReplyState {
  final List<MsgReplyItem>? items;
  final Cursor? cursor;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;

  const MsgReplyState({
    this.items,
    this.cursor,
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
  });

  MsgReplyState copyWith({
    List<MsgReplyItem>? items,
    Cursor? cursor,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
  }) {
    return MsgReplyState(
      items: items ?? this.items,
      cursor: cursor ?? this.cursor,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Controller for managing reply messages
@riverpod
class MsgReplyController extends _$MsgReplyController {
  @override
  MsgReplyState build() {
    return const MsgReplyState();
  }

  /// Fetch reply messages
  Future<void> fetchReplyMessages({
    int? cursor,
    int? cursorTime,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = const MsgReplyState();
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final getReply = ref.read(getReplyMessagesProvider);
      final result = await getReply(
        cursor: cursor,
        cursorTime: cursorTime,
      );

      switch (result) {
        case Success(:final response):
          final newItems = response.items ?? [];
          final existingItems = refresh ? [] : (state.items ?? []);

          state = state.copyWith(
            items: [...existingItems, ...newItems],
            cursor: response.cursor,
            isLoading: false,
            hasMore: response.cursor?.isEnd == false,
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

    await fetchReplyMessages(
      cursor: state.cursor?.id,
      cursorTime: state.cursor?.time,
    );
  }

  /// Refresh messages
  Future<void> refresh() async {
    await fetchReplyMessages(refresh: true);
  }

  /// Clear messages
  void clearMessages() {
    state = const MsgReplyState();
  }
}
