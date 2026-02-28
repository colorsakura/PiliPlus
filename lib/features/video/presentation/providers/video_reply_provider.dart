import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show MainListReply, Mode;
import 'package:PiliPlus/grpc/bilibili/pagination.pb.dart'
    show FeedPaginationReply;
import 'package:PiliPlus/grpc/reply.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/reply/reply_sort_type.dart';
import 'package:PiliPlus/models/common/video/video_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'video_states.dart';

/// Video reply notifier - manages comment/reply state
class VideoReplyNotifier extends Notifier<VideoReplyState> {
  @override
  VideoReplyState build() {
    return VideoReplyState.initial();
  }

  AnimationController? _fabAnimationCtr;
  Animation<Offset>? animation;

  Mode get _mode =>
      state.sortType == ReplySortType.time ? Mode.MAIN_LIST_TIME : Mode.MAIN_LIST_HOT;
  bool get _isPugv => (state.args['videoType'] as VideoType?) == VideoType.pugv;

  /// Initialize the notifier with args
  void setArgs(Map<String, dynamic> args) {
    state = state.copyWith(
      args: args,
      count: 0,
      sortType: Pref.replySortType,
    );
  }

  /// Initialize with ticker provider
  void initAnimation(TickerProvider vsync) {
    _fabAnimationCtr = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 100),
    )..forward();
    animation = _fabAnimationCtr!.drive(
      Tween<Offset>(
        begin: const Offset(0.0, 2.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut)),
    );
  }

  /// Toggle sort type (time/hot)
  void queryBySort() {
    if (state.isLoading) return;

    final newSortType = state.sortType == ReplySortType.time
        ? ReplySortType.hot
        : ReplySortType.time;

    state = state.copyWith(sortType: newSortType);
    onReload();
  }

  /// Reload comments
  Future<void> onReload() async {
    await onRefresh();
  }

  /// Refresh comments
  Future<void> onRefresh() async {
    state = state.copyWith(
      isLoading: true,
      cursorNext: null,
      subjectControl: null,
      paginationReply: null,
    );

    try {
      final oid = _isPugv ? state.args['epId'] ?? state.args['aid'] : state.args['aid'];
      final videoType = state.args['videoType'] as VideoType;

      final result = await ReplyGrpc.mainList(
        oid: oid as int,
        type: videoType.replyType,
        mode: _mode,
        cursorNext: null,
        offset: null,
      );

      if (result is Success<MainListReply>) {
        final response = result.response;
        state = state.copyWith(
          loadingState: result,
          count: response.subjectControl.count.toInt(),
          hasUpTop: response.upTop != null,
          subjectControl: response.subjectControl,
          upMid: state.upMid ?? response.subjectControl.upMid.toInt(),
          cursorNext: response.cursor.next,
          paginationReply: response.paginationReply,
          isLoading: false,
          isEnd: response.cursor.isEnd,
        );
      } else {
        state = state.copyWith(
          loadingState: result,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        loadingState: Error(e.toString()),
        isLoading: false,
      );
    }
  }

  /// Load more comments
  Future<void> onLoadMore() async {
    if (state.isLoading || state.isEnd) return;

    state = state.copyWith(isLoading: true);

    try {
      final oid = _isPugv ? state.args['epId'] ?? state.args['aid'] : state.args['aid'];
      final videoType = state.args['videoType'] as VideoType;

      final result = await ReplyGrpc.mainList(
        oid: oid as int,
        type: videoType.replyType,
        mode: _mode,
        cursorNext: state.cursorNext,
        offset: state.paginationReply?.nextOffset,
      );

      if (result is Success<MainListReply>) {
        final response = result.response;

        // Append new replies to existing list
        final currentState = state.loadingState;
        if (currentState is Success<MainListReply>) {
          final existingReplies = currentState.response.replies.toList();
          final allReplies = [...existingReplies, ...response.replies];
          final updatedResponse = MainListReply(
            subjectControl: response.subjectControl,
            cursor: response.cursor,
            replies: allReplies,
            upTop: response.upTop,
            paginationReply: response.paginationReply,
          );

          state = state.copyWith(
            loadingState: Success(updatedResponse),
            cursorNext: response.cursor.next,
            paginationReply: response.paginationReply,
            isLoading: false,
            isEnd: response.cursor.isEnd,
          );
        } else {
          state = state.copyWith(
            loadingState: result,
            cursorNext: response.cursor.next,
            paginationReply: response.paginationReply,
            isLoading: false,
            isEnd: response.cursor.isEnd,
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Get reply hint (input disable state and hint text)
  (bool inputDisable, String? hint) get replyHint {
    final subjectControl = state.subjectControl;
    if (subjectControl == null) {
      return (false, null);
    }

    String? hint;
    bool inputDisable = subjectControl.inputDisable;

    if (subjectControl.hasRootText()) {
      final rootText = subjectControl.rootText;
      if (inputDisable) {
        // SmartDialog.showToast(rootText);
      }
      if (rootText.contains('可发') || rootText.contains('可见')) {
        hint = rootText;
      }
    }

    return (inputDisable, hint);
  }

  /// Show FAB
  void showFab() {
    if (!state.isFabVisible) {
      state = state.copyWith(isFabVisible: true);
      _fabAnimationCtr?.forward();
    }
  }

  /// Hide FAB
  void hideFab() {
    if (state.isFabVisible) {
      state = state.copyWith(isFabVisible: false);
      _fabAnimationCtr?.reverse();
    }
  }
}

/// Provider for reply controller
final videoReplyProvider = NotifierProvider<VideoReplyNotifier, VideoReplyState>(
  VideoReplyNotifier.new,
);
