import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/dynamics_create/domain/entities/dynamic_publish_params.dart';

/// Data source interface for dynamic publishing operations
abstract class DynamicPublishRemoteDataSource {
  /// Create a new dynamic post via API
  Future<LoadingState<Map<String, dynamic>?>> createDynamic(CreateDynamicParams params);

  /// Edit an existing dynamic post via API
  Future<LoadingState<Null>> editDynamic(EditDynamicParams params);
}
