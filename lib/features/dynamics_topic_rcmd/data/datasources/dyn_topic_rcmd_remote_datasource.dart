import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';

/// Dynamics topic recommendation remote data source
class DynTopicRcmdRemoteDataSource {
  /// Get dynamics topic recommendation from API
  Future<LoadingState<List<TopicItem>?>> getDynTopicRcmd({
    int ps = 25,
  }) {
    return DynamicsHttp.dynTopicRcmd(ps: ps);
  }
}
