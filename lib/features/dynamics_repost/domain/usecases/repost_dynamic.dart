import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/dynamics_repost/domain/entities/dynamics_repost_params.dart';
import 'package:PiliPlus/features/dynamics_repost/domain/repositories/dynamics_repost_repository.dart';

/// Use case for creating/reposting a dynamic
class RepostDynamic {
  final DynamicsRepostRepository repository;

  const RepostDynamic(this.repository);

  /// Execute the repost operation
  ///
  /// [params] contains all necessary parameters
  ///
  /// Returns [Success] with response data (including dyn_id) if successful,
  /// or [Error] if failed
  Future<LoadingState<Map?>> call(DynamicsRepostParams params) {
    return repository.repostDynamic(params);
  }
}
