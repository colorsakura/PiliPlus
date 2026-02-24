import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';

/// Dynamics topic recommendation repository interface
abstract interface class DynTopicRcmdRepository {
  /// Get dynamics topic recommendation list
  Future<LoadingState<List<TopicItem>?>> getDynTopicRcmd();
}
