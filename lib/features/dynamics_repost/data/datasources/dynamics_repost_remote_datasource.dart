import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/dynamics_repost/domain/entities/dynamics_repost_params.dart';

/// Data source interface for dynamic repost operations
abstract class DynamicsRepostRemoteDataSource {
  /// Create or repost a dynamic via API
  ///
  /// [params] contains all necessary parameters for the operation
  ///
  /// Returns [Success] with the created dynamic ID, or [Error] if failed
  Future<LoadingState<Map?>> repostDynamic(DynamicsRepostParams params);
}
