import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/share/domain/entities/share_user.dart';

/// Share repository interface
abstract class ShareRepository {
  /// Send share content to selected users
  Future<LoadingState<Map<int, bool>>> sendShare({
    required List<ShareUserEntity> users,
    required Map content,
    String? message,
  });
}
