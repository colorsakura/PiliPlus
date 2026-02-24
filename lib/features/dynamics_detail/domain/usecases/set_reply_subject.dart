import 'package:PiliPlus/features/dynamics_detail/domain/repositories/dyn_detail_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for modifying reply subject settings
class SetReplySubject {
  final DynDetailRepository _repository;

  const SetReplySubject(this._repository);

  Future<LoadingState> call({
    required int oid,
    required int type,
    required int action,
  }) {
    return _repository.setReplySubject(
      oid: oid,
      type: type,
      action: action,
    );
  }
}
