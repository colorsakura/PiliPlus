import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/msg/domain/usecases/get_msg_feed_unread.dart';
import 'package:PiliPlus/features/msg/data/repositories/msg_repository_impl.dart';
import 'package:PiliPlus/features/msg/data/datasources/msg_remote_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

part 'msg_unread_controller.g.dart';

/// Provider for MsgRemoteDataSource
final msgRemoteDataSourceProvider = Provider<MsgRemoteDataSource>((ref) {
  return MsgRemoteDataSource();
});

/// Provider for MsgRepository
final msgRepositoryProvider = Provider<MsgRepositoryImpl>((ref) {
  final datasource = ref.watch(msgRemoteDataSourceProvider);
  return MsgRepositoryImpl(remoteDataSource: datasource);
});

/// Provider for GetMsgFeedUnread use case
final getMsgFeedUnreadProvider = Provider<GetMsgFeedUnread>((ref) {
  final repository = ref.watch(msgRepositoryProvider);
  return GetMsgFeedUnread(repository);
});

/// Message unread state
class MsgUnreadState {
  final int replyUnread;
  final int atUnread;
  final int likeUnread;
  final bool isLoading;
  final String? errorMessage;

  const MsgUnreadState({
    this.replyUnread = 0,
    this.atUnread = 0,
    this.likeUnread = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  int get totalUnread => replyUnread + atUnread + likeUnread;

  MsgUnreadState copyWith({
    int? replyUnread,
    int? atUnread,
    int? likeUnread,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MsgUnreadState(
      replyUnread: replyUnread ?? this.replyUnread,
      atUnread: atUnread ?? this.atUnread,
      likeUnread: likeUnread ?? this.likeUnread,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for managing message unread counts
@riverpod
class MsgUnreadController extends _$MsgUnreadController {
  @override
  MsgUnreadState build() {
    // Fetch unread data on initialization
    fetchUnread();
    return const MsgUnreadState();
  }

  /// Fetch unread message counts
  Future<void> fetchUnread() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final getUnread = ref.read(getMsgFeedUnreadProvider);
      final result = await getUnread();

      switch (result) {
        case Success(:final response):
          state = state.copyWith(
            replyUnread: response.reply ?? 0,
            atUnread: response.at ?? 0,
            likeUnread: response.like ?? 0,
            isLoading: false,
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

  /// Clear unread count for specific type
  void clearUnread(String type) {
    switch (type) {
      case 'reply':
        state = state.copyWith(replyUnread: 0);
        break;
      case 'at':
        state = state.copyWith(atUnread: 0);
        break;
      case 'like':
        state = state.copyWith(likeUnread: 0);
        break;
    }
  }

  /// Clear all unread counts
  void clearAllUnread() {
    state = state.copyWith(
      replyUnread: 0,
      atUnread: 0,
      likeUnread: 0,
    );
  }
}
