import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/dynamics_create/domain/entities/dynamic_publish_params.dart';
import 'package:PiliPlus/features/dynamics_create/domain/repositories/dynamic_publish_repository.dart';

/// Use case for editing a dynamic post
class EditDynamic {
  final DynamicPublishRepository repository;

  const EditDynamic(this.repository);

  Future<LoadingState<Null>> call(EditDynamicParams params) =>
      repository.editDynamic(params);
}
