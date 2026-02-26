import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/dynamics_create/domain/entities/dynamic_publish_params.dart';
import 'package:PiliPlus/features/dynamics_create/domain/repositories/dynamic_publish_repository.dart';

/// Use case for creating a dynamic post
class CreateDynamic {
  final DynamicPublishRepository repository;

  const CreateDynamic(this.repository);

  Future<LoadingState<Map<String, dynamic>?>> call(CreateDynamicParams params) =>
      repository.createDynamic(params);
}
