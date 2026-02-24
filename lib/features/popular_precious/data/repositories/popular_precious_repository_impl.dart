import 'package:PiliPlus/features/popular_precious/domain/entities/popular_precious_item_entity.dart';
import 'package:PiliPlus/features/popular_precious/domain/repositories/popular_precious_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';

/// Implementation of popular precious repository
class PopularPreciousRepositoryImpl implements PopularPreciousRepository {
  const PopularPreciousRepositoryImpl();

  @override
  Future<LoadingState<List<PopularPreciousItemEntity>>> fetchPopularPrecious({
    required int page,
  }) async {
    final result = await VideoHttp.popularPrecious(page: page);

    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        final items = data.list ?? [];
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
