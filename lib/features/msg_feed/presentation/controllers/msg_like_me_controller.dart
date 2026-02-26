import 'package:PiliPlus/shared/widgets/pair.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/msg/msg_like/item.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

/// Like me messages controller - V2 Riverpod version
class MsgLikeMeController extends ChangeNotifier {
  MsgLikeMeState _state = MsgLikeMeState();

  MsgLikeMeState get state => _state;

  void _updateState(MsgLikeMeState newState) {
    _state = newState;
    notifyListeners();
  }

  int? cursor;
  int? cursorTime;

  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading) return;
    if (!isRefresh && _state.isEnd) return;

    _updateState(_state.copyWith(isLoading: true));

    try {
      final result = await MsgHttp.msgFeedLikeMe(
        cursor: isRefresh ? null : cursor,
        cursorTime: isRefresh ? null : cursorTime,
      );

      if (result case Success(:final response)) {
        final data = response;

        // Check if reached end
        final isEnd =
            data.total?.cursor?.isEnd == true ||
            data.total?.items.isNullOrEmpty == true;

        cursor = data.total?.cursor?.id;
        cursorTime = data.total?.cursor?.time;

        List<MsgLikeItem> latest = data.latest?.items ?? <MsgLikeItem>[];
        List<MsgLikeItem> total = data.total?.items ?? <MsgLikeItem>[];

        List<MsgLikeItem> finalLatest;
        List<MsgLikeItem> finalTotal;

        if (!isRefresh &&
            _state.loadingState
                is Success<Pair<List<MsgLikeItem>, List<MsgLikeItem>>>) {
          final response =
              (_state.loadingState
                      as Success<Pair<List<MsgLikeItem>, List<MsgLikeItem>>>)
                  .response;
          // Append for pagination
          finalLatest = [...response.first, ...latest];
          finalTotal = [...response.second, ...total];
        } else {
          finalLatest = latest;
          finalTotal = total;
        }

        _updateState(
          _state.copyWith(
            isLoading: false,
            loadingState: Success(Pair(first: finalLatest, second: finalTotal)),
            latestItems: finalLatest,
            totalItems: finalTotal,
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

  Future<void> onRemove(dynamic id, num index, bool isLatest) async {
    try {
      final res = await MsgHttp.delMsgfeed(0, id);
      if (res.isSuccess) {
        if (isLatest) {
          final newItems = List<MsgLikeItem>.from(_state.latestItems);
          newItems.removeAt(index.toInt());
          _updateState(_state.copyWith(latestItems: newItems));
        } else {
          final newItems = List<MsgLikeItem>.from(_state.totalItems);
          newItems.removeAt(index.toInt());
          _updateState(_state.copyWith(totalItems: newItems));
        }
        SmartDialog.showToast('删除成功');
      } else {
        res.toast();
      }
    } catch (_) {}
  }

  Future<void> onSetNotice(MsgLikeItem item, bool isNotice) async {
    int noticeState = isNotice ? 1 : 0;
    final res = await MsgHttp.msgSetNotice(
      id: item.id!,
      noticeState: noticeState,
    );
    if (res.isSuccess) {
      item.noticeState = noticeState;
      notifyListeners();
      SmartDialog.showToast('操作成功');
    } else {
      res.toast();
    }
  }

  Future<void> onRefresh() async {
    cursor = null;
    cursorTime = null;
    await queryData(isRefresh: true);
  }
}

@immutable
class MsgLikeMeState {
  final bool isLoading;
  final LoadingState loadingState;
  final List<MsgLikeItem> latestItems;
  final List<MsgLikeItem> totalItems;
  final bool isEnd;
  final String? error;

  MsgLikeMeState({
    this.isLoading = false,
    LoadingState? loadingState,
    this.latestItems = const [],
    this.totalItems = const [],
    this.isEnd = false,
    this.error,
  }) : loadingState = loadingState ?? LoadingState.loading();

  MsgLikeMeState copyWith({
    bool? isLoading,
    LoadingState? loadingState,
    List<MsgLikeItem>? latestItems,
    List<MsgLikeItem>? totalItems,
    bool? isEnd,
    String? error,
  }) {
    return MsgLikeMeState(
      isLoading: isLoading ?? this.isLoading,
      loadingState: loadingState ?? this.loadingState,
      latestItems: latestItems ?? this.latestItems,
      totalItems: totalItems ?? this.totalItems,
      isEnd: isEnd ?? this.isEnd,
      error: error ?? this.error,
    );
  }
}

final msgLikeMeControllerProvider = Provider<MsgLikeMeController>((ref) {
  final controller = MsgLikeMeController();
  ref.onDispose(controller.dispose);
  return controller;
});
