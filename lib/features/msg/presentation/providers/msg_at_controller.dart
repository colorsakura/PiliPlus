import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/msg/domain/usecases/get_at_messages.dart';
import 'package:PiliPlus/features/msg/presentation/providers/msg_unread_controller.dart';
import 'package:PiliPlus/models/msg/msg_at/item.dart';
import 'package:PiliPlus/models/msg/msg_at/cursor.dart';
import 'package:PiliPlus/http/loading_state.dart';

part 'msg_at_controller.g.dart';

/// Provider for GetAtMessages use case
final getAtMessagesProvider = Provider<GetAtMessages>((ref) {
  final repository = ref.watch(msgRepositoryProvider);
  return GetAtMessages(repository);
});

/// At messages state
class MsgAtState {
  final List<MsgAtItem>? items;
  final Cursor? cursor;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;

  const MsgAtState({
    this.items,
    this.cursor,
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
  });

  MsgAtState copyWith({
    List<MsgAtItem>? items,
    Cursor? cursor,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
  }) {
    return MsgAtState(
      items: items ?? this.items,
      cursor: cursor ?? this.cursor,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Controller for managing at messages
@riverpod
class MsgAtController extends _$MsgAtController {
  @override
  MsgAtState build() {
    return const MsgAtState();
  }

  /// Fetch at messages
  Future<void> fetchAtMessages({
    int? cursor,
    int? cursorTime,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = const MsgAtState();
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final getAt = ref.read(getAtMessagesProvider);
      final result = await getAt(
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

    await fetchAtMessages(
      cursor: state.cursor?.id,
      cursorTime: state.cursor?.time,
    );
  }

  /// Refresh messages
  Future<void> refresh() async {
    await fetchAtMessages(refresh: true);
  }

  /// Clear messages
  void clearMessages() {
    state = const MsgAtState();
  }
}
