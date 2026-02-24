import 'package:PiliPlus/features/dynamics_detail/domain/repositories/dyn_detail_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching dynamic detail
class GetDynamicDetail {
  final DynDetailRepository _repository;

  const GetDynamicDetail(this._repository);

  Future<LoadingState<dynamic>> call({required String id}) {
    return _repository.dynamicDetail(id: id);
  }
}
