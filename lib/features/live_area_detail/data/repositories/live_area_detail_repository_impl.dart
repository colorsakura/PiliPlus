import 'package:PiliPlus/features/live_area_detail/domain/entities/live_area_item_entity.dart';
import 'package:PiliPlus/features/live_area_detail/domain/repositories/live_area_detail_repository.dart';
import 'package:PiliPlus/http/live.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of live area detail repository
class LiveAreaDetailRepositoryImpl implements LiveAreaDetailRepository {
  const LiveAreaDetailRepositoryImpl();

  @override
  Future<LoadingState<List<LiveAreaItemEntity>>> fetchLiveAreaDetail({
    required dynamic parentAreaId,
  }) async {
    final result = await LiveHttp.liveRoomAreaList(parentid: parentAreaId);

    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        final items = data ?? [];
        return Success(items);
      },
      error: (errMsg, {code}) => Error(errMsg, code: code),
    );
  }
}

/// Extension on LoadingState to provide pattern matching
extension LoadingStateExtension<T> on LoadingState<T> {
  R when<R>({
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String? errMsg, {int? code}) error,
  }) {
    if (this is Loading) {
      return loading();
    } else if (this is Success<T>) {
      return success((this as Success<T>).response);
    } else if (this is Error) {
      final err = this as Error;
      return error(err.errMsg, code: err.code);
    }
    throw StateError('Invalid LoadingState type');
  }
}
