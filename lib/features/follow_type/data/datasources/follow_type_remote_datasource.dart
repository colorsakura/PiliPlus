import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/features/follow_type/domain/entities/follow_type_params.dart';

/// Data source interface for follow type operations
abstract class FollowTypeRemoteDataSource {
  /// Fetch users who follow the specified user via API
  Future<LoadingState<FollowData>> fetchFollowed(FollowedParams params);

  /// Fetch users with mutual follows via API
  Future<LoadingState<FollowData>> fetchFollowSame(FollowSameParams params);
}
