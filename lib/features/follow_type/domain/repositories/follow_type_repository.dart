import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/features/follow_type/domain/entities/follow_type_params.dart';

/// Repository interface for follow type operations
abstract class FollowTypeRepository {
  /// Fetch users who follow the specified user (followers)
  Future<LoadingState<FollowData>> fetchFollowed(FollowedParams params);

  /// Fetch users with mutual follows
  Future<LoadingState<FollowData>> fetchFollowSame(FollowSameParams params);
}
