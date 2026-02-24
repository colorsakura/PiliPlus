import 'package:flutter/foundation.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/domain/usecases/get_dyn_topic_rcmd.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';

/// Dynamics topic recommendation state
class DynTopicRcmdState {
  final LoadingState<List<TopicItem>?> topicListState;

  const DynTopicRcmdState({
    required this.topicListState,
  });

  DynTopicRcmdState copyWith({
    LoadingState<List<TopicItem>?>? topicListState,
  }) {
    return DynTopicRcmdState(
      topicListState: topicListState ?? this.topicListState,
    );
  }
}

/// Dynamics topic recommendation controller
class DynTopicRcmdController extends ChangeNotifier {
  final GetDynTopicRcmdUseCase _getDynTopicRcmdUseCase;

  DynTopicRcmdState _state = DynTopicRcmdState(
    topicListState: LoadingState.loading(),
  );

  DynTopicRcmdState get state => _state;

  DynTopicRcmdController({
    required GetDynTopicRcmdUseCase getDynTopicRcmdUseCase,
  }) : _getDynTopicRcmdUseCase = getDynTopicRcmdUseCase {
    // Load initial data
    Future.microtask(() => queryTopicList());
  }

  void _updateState(DynTopicRcmdState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Query topic recommendation list
  Future<void> queryTopicList() async {
    final result = await _getDynTopicRcmdUseCase();
    _updateState(_state.copyWith(topicListState: result));
  }

  /// Refresh topic list
  Future<void> onRefresh() async {
    await queryTopicList();
  }

  /// Reload on error
  void onReload() {
    queryTopicList();
  }
}
