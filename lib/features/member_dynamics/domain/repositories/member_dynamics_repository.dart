import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/result.dart';

/// Repository for member dynamics data
abstract class MemberDynamicsRepository {
  /// Get member dynamics with pagination
  Future<LoadingState<DynamicsDataModel>> getMemberDynamics({
    required int mid,
    required String offset,
  });

  /// Remove a dynamic post
  Future<LoadingState<void>> removeDynamic({required dynamic dynIdStr});

  /// Set/unset dynamic as top
  Future<LoadingState<void>> setDynamicTop({
    required dynamic dynamicId,
    required bool isTop,
  });
}
