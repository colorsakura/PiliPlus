import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/dynamics_create/domain/entities/dynamic_publish_params.dart';

/// Repository interface for dynamic publishing operations
abstract class DynamicPublishRepository {
  /// Create a new dynamic post
  Future<LoadingState<Map<String, dynamic>?>> createDynamic(CreateDynamicParams params);

  /// Edit an existing dynamic post
  Future<LoadingState<Null>> editDynamic(EditDynamicParams params);
}
