import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Repository interface for follow search
abstract class FollowSearchRepository {
  /// Search followed users by name
  Future<LoadingState<FollowData>> searchFollows({
    required int mid,
    required String name,
    required int page,
    required int pageSize,
  });
}
