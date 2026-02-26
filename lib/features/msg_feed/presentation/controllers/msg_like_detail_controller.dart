import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/msg/msg_like_detail/card.dart';
import 'package:PiliPlus/models/msg/msg_like_detail/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Like detail controller - V2 Riverpod version
class LikeDetailController extends ChangeNotifier {
  LikeDetailController({
    required this.cardId,
    this.uri,
    required this.counts,
  });

  final String cardId;
  final String? uri;
  final int counts;

  LikeDetailState _state = LikeDetailState();

  LikeDetailState get state => _state;

  void _updateState(LikeDetailState newState) {
    _state = newState;
    notifyListeners();
  }

  int _page = 1;
  int lastMid = 0;
  bool _isEnd = false;

  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading || (!isRefresh && _isEnd)) return;

    _updateState(_state.copyWith(isLoading: true));

    try {
      final result = await MsgHttp.msgLikeDetail(
        cardId: cardId,
        pn: isRefresh ? 1 : _page,
        lastMid: isRefresh ? 0 : lastMid,
      );

      if (result case Success(:final response)) {
        final items = response.items ?? [];
        final card = response.card;

        if (items.lastOrNull?.user?.mid case final mid?) {
          lastMid = mid;
        }

        final allItems = isRefresh ? items : [..._state.items, ...items];
        final isEnd = allItems.length >= counts;

        _page++;
        _isEnd = isEnd;

        _updateState(
          _state.copyWith(
            isLoading: false,
            loadingState: Success(allItems),
            items: allItems,
            card: card,
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

  Future<void> onRefresh() async {
    lastMid = 0;
    _page = 1;
    _isEnd = false;
    await queryData(isRefresh: true);
  }

  Future<void> onLoadMore() => queryData(isRefresh: false);
}

@immutable
class LikeDetailState {
  final bool isLoading;
  final LoadingState loadingState;
  final List<MsgLikeDetailItem> items;
  final MsgLikeDetailCard? card;
  final bool isEnd;
  final String? error;
  final String? uri;

  LikeDetailState({
    this.isLoading = false,
    LoadingState? loadingState,
    this.items = const [],
    this.card,
    this.isEnd = false,
    this.error,
    this.uri,
  }) : loadingState = loadingState ?? LoadingState.loading();

  LikeDetailState copyWith({
    bool? isLoading,
    LoadingState? loadingState,
    List<MsgLikeDetailItem>? items,
    MsgLikeDetailCard? card,
    bool? isEnd,
    String? error,
    String? uri,
  }) {
    return LikeDetailState(
      isLoading: isLoading ?? this.isLoading,
      loadingState: loadingState ?? LoadingState.loading(),
      items: items ?? this.items,
      card: card ?? this.card,
      isEnd: isEnd ?? this.isEnd,
      error: error ?? this.error,
      uri: uri ?? this.uri,
    );
  }
}

/// Provider for LikeDetailController
final likeDetailControllerProvider =
    Provider.family<
      LikeDetailController,
      ({String cardId, String? uri, int counts})
    >((ref, args) {
      final controller = LikeDetailController(
        cardId: args.cardId,
        uri: args.uri,
        counts: args.counts,
      );
      ref.onDispose(controller.dispose);
      return controller;
    });
