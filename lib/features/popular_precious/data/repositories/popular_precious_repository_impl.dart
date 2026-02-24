import 'package:PiliPlus/features/popular_precious/domain/entities/popular_precious_item_entity.dart';
import 'package:PiliPlus/features/popular_precious/domain/repositories/popular_precious_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/popular/popular_precious/data.dart';

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
