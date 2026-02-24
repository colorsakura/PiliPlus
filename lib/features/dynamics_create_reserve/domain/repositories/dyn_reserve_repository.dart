import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_reserve_info/data.dart';

/// Dynamics reserve repository interface
abstract interface class DynReserveRepository {
  /// Get reserve info
  Future<LoadingState<ReserveInfoData>> getReserveInfo({required int sid});

  /// Create reserve
  Future<LoadingState<int?>> createReserve({
    required String title,
    required int subType,
    required int livePlanStartTime,
  });

  /// Update reserve
  Future<LoadingState<void>> updateReserve({
    required int sid,
    required int subType,
    required String title,
    required int livePlanStartTime,
  });
}
