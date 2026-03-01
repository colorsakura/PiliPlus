import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/msg/msg_sys/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/utils/toast_utils.dart';

/// System messages controller - V2 Riverpod version
class MsgSysMsgController extends ChangeNotifier {
  MsgSysMsgState _state = MsgSysMsgState();

  MsgSysMsgState get state => _state;

  void _updateState(MsgSysMsgState newState) {
    _state = newState;
    notifyListeners();
  }

  int? cursor;

  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading) return;

    _updateState(_state.copyWith(isLoading: true));

    try {
      final result = await MsgHttp.msgFeedNotify(
        cursor: isRefresh ? null : cursor,
      );

      if (result case Success(:final response)) {
        final items = response ?? [];

        if (cursor == null && items.isNotEmpty) {
          msgSysUpdateCursor(items.first.cursor);
        }
        cursor = items.isNotEmpty ? items.last.cursor : cursor;

        final allItems = isRefresh ? items : [..._state.items, ...items];

        _updateState(
          _state.copyWith(
            isLoading: false,
            loadingState: Success(allItems),
            items: allItems,
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

  void msgSysUpdateCursor(int? cursor) {
    if (cursor != null) {
      MsgHttp.msgSysUpdateCursor(cursor);
    }
  }

  Future<void> onRemove(dynamic id, int index) async {
    try {
      final res = await MsgHttp.delSysMsg(id);
      if (res.isSuccess) {
        final newItems = List<MsgSysItem>.from(_state.items);
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
    await queryData(isRefresh: true);
  }
}

@immutable
class MsgSysMsgState {
  final bool isLoading;
  final LoadingState loadingState;
  final List<MsgSysItem> items;
  final String? error;

  MsgSysMsgState({
    this.isLoading = false,
    LoadingState? loadingState,
    this.items = const [],
    this.error,
  }) : loadingState = loadingState ?? LoadingState.loading();

  MsgSysMsgState copyWith({
    bool? isLoading,
    LoadingState? loadingState,
    List<MsgSysItem>? items,
    String? error,
  }) {
    return MsgSysMsgState(
      isLoading: isLoading ?? this.isLoading,
      loadingState: loadingState ?? this.loadingState,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }
}

final msgSysMsgControllerProvider = Provider<MsgSysMsgController>((ref) {
  final controller = MsgSysMsgController();
  ref.onDispose(controller.dispose);
  return controller;
});
