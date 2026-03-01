import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/msg/msg_reply/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/utils/toast_utils.dart';

/// Reply to me messages controller - V2 Riverpod version
class MsgReplyMeController extends ChangeNotifier {
  MsgReplyMeState _state = MsgReplyMeState();

  MsgReplyMeState get state => _state;

  void _updateState(MsgReplyMeState newState) {
    _state = newState;
    notifyListeners();
  }

  int? cursor;
  int? cursorTime;

  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading) return;

    _updateState(_state.copyWith(isLoading: true));

    try {
      final result = await MsgHttp.msgFeedReplyMe(
        cursor: isRefresh ? null : cursor,
        cursorTime: isRefresh ? null : cursorTime,
      );

      if (result case Success(:final response)) {
        final items = response.items ?? [];
        final isEnd = response.cursor?.isEnd == true;

        cursor = response.cursor?.id;
        cursorTime = response.cursor?.time;

        final allItems = isRefresh ? items : [..._state.items, ...items];

        _updateState(
          _state.copyWith(
            isLoading: false,
            loadingState: Success(allItems),
            items: allItems,
            isEnd: isEnd,
            error: null,
          ),
        );
      } else if (result case Error(:final errMsg)) {
        _updateState(
          _state.copyWith(
            isLoading: false,
            error: errMsg,
          ),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          isLoading: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> onRemove(dynamic id, int index) async {
    try {
      final res = await MsgHttp.delMsgfeed(1, id);
      if (res.isSuccess) {
        final newItems = List<MsgReplyItem>.from(_state.items);
        newItems.removeAt(index);
        _updateState(_state.copyWith(items: newItems));
        ToastUtils.showToast('删除成功');
      } else {
        res.toast();
      }
    } catch (_) {}
  }

  Future<void> onRefresh() async {
    cursor = null;
    cursorTime = null;
    await queryData(isRefresh: true);
  }
}

@immutable
class MsgReplyMeState {
  final bool isLoading;
  final LoadingState loadingState;
  final List<MsgReplyItem> items;
  final bool isEnd;
  final String? error;

  MsgReplyMeState({
    this.isLoading = false,
    LoadingState? loadingState,
    this.items = const [],
    this.isEnd = false,
    this.error,
  }) : loadingState = loadingState ?? LoadingState.loading();

  MsgReplyMeState copyWith({
    bool? isLoading,
    LoadingState? loadingState,
    List<MsgReplyItem>? items,
    bool? isEnd,
    String? error,
  }) {
    return MsgReplyMeState(
      isLoading: isLoading ?? this.isLoading,
      loadingState: loadingState ?? this.loadingState,
      items: items ?? this.items,
      isEnd: isEnd ?? this.isEnd,
      error: error ?? this.error,
    );
  }
}

final msgReplyMeControllerProvider = Provider<MsgReplyMeController>((ref) {
  final controller = MsgReplyMeController();
  ref.onDispose(controller.dispose);
  return controller;
});
