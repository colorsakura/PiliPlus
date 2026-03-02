import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/domain/usecases/get_dyn_topic_rcmd.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/presentation/providers/dyn_topic_rcmd_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';

part 'dyn_topic_rcmd_controller_v2.g.dart';

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

/// Dynamics topic recommendation controller (Riverpod version)
@riverpod
class DynTopicRcmdController extends _$DynTopicRcmdController {
  @override
  DynTopicRcmdState build() {
    // Load initial data
    Future.microtask(() => queryTopicList());

    return DynTopicRcmdState(
      topicListState: LoadingState.loading(),
    );
  }

  /// Query topic recommendation list
  Future<void> queryTopicList() async {
    final getDynTopicRcmdUseCase = ref.read(getDynTopicRcmdUseCaseProvider);
    final result = await getDynTopicRcmdUseCase();
    state = state.copyWith(topicListState: result);
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
