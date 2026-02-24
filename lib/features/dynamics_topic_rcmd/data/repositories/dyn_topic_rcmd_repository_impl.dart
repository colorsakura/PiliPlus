import 'package:PiliPlus/features/dynamics_topic_rcmd/data/datasources/dyn_topic_rcmd_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/domain/repositories/dyn_topic_rcmd_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';

/// Dynamics topic recommendation repository implementation
class DynTopicRcmdRepositoryImpl implements DynTopicRcmdRepository {
  final DynTopicRcmdRemoteDataSource _remoteDataSource;

  const DynTopicRcmdRepositoryImpl(this._remoteDataSource);

  @override
  Future<LoadingState<List<TopicItem>?>> getDynTopicRcmd() {
    return _remoteDataSource.getDynTopicRcmd();
  }
}
