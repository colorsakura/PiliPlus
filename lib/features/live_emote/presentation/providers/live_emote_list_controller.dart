import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/models/live/live_emote/datum.dart';
import 'package:PiliPlus/features/live_emote/domain/usecases/get_live_emoticons_usecase.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/live_emote/presentation/providers/live_emote_providers.dart';

part 'live_emote_list_controller.g.dart';

/// State for live emote
class LiveEmoteListState {
  const LiveEmoteListState({
    required this.listState,
  });

  final LoadingState<List<LiveEmoteDatum>?> listState;

  LiveEmoteListState copyWith({
    LoadingState<List<LiveEmoteDatum>?>? listState,
  }) {
    return LiveEmoteListState(
      listState: listState ?? this.listState,
    );
  }
}

/// Controller for live emote (Riverpod version with family parameter)
@riverpod
class LiveEmoteListController extends _$LiveEmoteListController {
  @override
  LiveEmoteListState build(int roomId) {
    // Fetch data on initialization
    queryData(roomId);
    return LiveEmoteListState(listState: LoadingState.loading());
  }

  /// Fetch live emote icons
  Future<void> queryData(int roomId) async {
    final getEmoticons = ref.read(getLiveEmoticonsUseCaseProvider);
    final result = await getEmoticons(roomId);

    final listState = switch (result) {
      Loading() => LoadingState<List<LiveEmoteDatum>?>.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };

    state = state.copyWith(listState: listState);
  }
}
