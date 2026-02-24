import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';

import '../entities/dynamics_data.dart';
import '../entities/follow_up.dart';

/// Repository interface for dynamics data.
abstract class DynamicsRepository {
  /// Get dynamics feed for a specific tab.
  Future<LoadingState<DynamicsDataEntity>> getDynamics({
    required DynamicsTabType tabType,
    String? offset,
  });

  /// Get follow-up UP users list.
  Future<LoadingState<FollowUpEntity>> getFollowUp({
    String? offset,
  });

  /// Get all followings (for showing all followed UPs).
  Future<LoadingState<List<UpItemEntity>>> getAllFollowings({
    required int mid,
    required int page,
  });

  /// Get dynamics UP list (paginated).
  Future<LoadingState<List<UpItemEntity>>> getDynamicsUpList({
    String? offset,
  });
}
