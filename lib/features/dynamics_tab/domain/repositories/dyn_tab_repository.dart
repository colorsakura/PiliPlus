import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';

/// Repository for dynamics tab operations
abstract class DynTabRepository {
  /// Fetch follow dynamics
  Future<LoadingState<dynamic>> followDynamic({
    required DynamicsTabType type,
    required String offset,
    int? mid,
    required Set<int> tempBannedList,
  });

  /// Remove a dynamic
  Future<LoadingState> removeDynamic({required String dynIdStr});
}
