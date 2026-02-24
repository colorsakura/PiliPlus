import 'package:PiliPlus/features/dynamics_topic_rcmd/domain/repositories/dyn_topic_rcmd_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';

/// Get dynamics topic recommendation use case
class GetDynTopicRcmdUseCase {
  final DynTopicRcmdRepository _repository;

  const GetDynTopicRcmdUseCase(this._repository);

  /// Execute the use case
  Future<LoadingState<List<TopicItem>?>> call() => _repository.getDynTopicRcmd();
}
