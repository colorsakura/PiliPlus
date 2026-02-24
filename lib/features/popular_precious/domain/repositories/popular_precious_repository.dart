import 'package:PiliPlus/features/popular_precious/domain/entities/popular_precious_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for popular precious data
abstract class PopularPreciousRepository {
  Future<LoadingState<List<PopularPreciousItemEntity>>> fetchPopularPrecious({
    required int page,
  });
}
