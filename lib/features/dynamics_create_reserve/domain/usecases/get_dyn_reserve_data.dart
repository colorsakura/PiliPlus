import 'package:PiliPlus/features/dynamics_create_reserve/domain/repositories/dyn_reserve_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_reserve_info/data.dart';

/// Get reserve info use case
class GetReserveInfoUseCase {
  final DynReserveRepository _repository;

  const GetReserveInfoUseCase(this._repository);

  Future<LoadingState<ReserveInfoData>> call({required int sid}) =>
      _repository.getReserveInfo(sid: sid);
}

/// Create reserve use case
class CreateReserveUseCase {
  final DynReserveRepository _repository;

  const CreateReserveUseCase(this._repository);

  Future<LoadingState<int?>> call({
    required String title,
    required int subType,
    required int livePlanStartTime,
  }) =>
      _repository.createReserve(
        title: title,
        subType: subType,
        livePlanStartTime: livePlanStartTime,
      );
}

/// Update reserve use case
class UpdateReserveUseCase {
  final DynReserveRepository _repository;

  const UpdateReserveUseCase(this._repository);

  Future<LoadingState<void>> call({
    required int sid,
    required int subType,
    required String title,
    required int livePlanStartTime,
  }) =>
      _repository.updateReserve(
        sid: sid,
        subType: subType,
        title: title,
        livePlanStartTime: livePlanStartTime,
      );
}
