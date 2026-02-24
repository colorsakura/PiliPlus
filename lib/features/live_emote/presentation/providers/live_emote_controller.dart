import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_emote/datum.dart';
import 'package:PiliPlus/features/live_emote/domain/usecases/get_live_emoticons_usecase.dart';

/// State for live emote
class LiveEmoteState {
  const LiveEmoteState({
    required this.listState,
  });

  final LoadingState<List<LiveEmoteDatum>?> listState;

  LiveEmoteState copyWith({
    LoadingState<List<LiveEmoteDatum>?>? listState,
  }) {
    return LiveEmoteState(
      listState: listState ?? this.listState,
    );
  }
}

/// Controller for live emote
class LiveEmoteController extends ChangeNotifier {
  LiveEmoteController({
    required this.roomId,
    required GetLiveEmoticonsUseCase getLiveEmoticonsUseCase,
  }) : _getLiveEmoticonsUseCase = getLiveEmoticonsUseCase,
       _state = LiveEmoteState(listState: LoadingState.loading()) {
    queryData();
  }

  final int roomId;
  final GetLiveEmoticonsUseCase _getLiveEmoticonsUseCase;

  LiveEmoteState _state;
  TabController? tabController;

  LiveEmoteState get state => _state;

  void _updateState(LiveEmoteState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Fetch live emote icons
  Future<void> queryData() async {
    final result = await _getLiveEmoticonsUseCase(roomId);

    final listState = switch (result) {
      Loading() => LoadingState<List<LiveEmoteDatum>?>.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };

    _updateState(_state.copyWith(listState: listState));

    // Initialize tab controller if data is available
    if (listState case Success(:final response)) {
      if (response != null && response.isNotEmpty) {
        // TabController needs to be initialized later when TickerProvider is available
        // The widget should call initTabController after build
      }
    }
  }

  /// Initialize tab controller (must be called after widget has vsync)
  void initTabController(TickerProvider vsync) {
    if (_state.listState case Success(:final response)) {
      if (response != null && response.isNotEmpty && tabController == null) {
        tabController = TabController(
          length: response.length,
          vsync: vsync,
        );
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}
