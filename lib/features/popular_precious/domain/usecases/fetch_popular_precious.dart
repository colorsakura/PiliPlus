import 'package:PiliPlus/features/popular_precious/domain/entities/popular_precious_item_entity.dart';
import 'package:PiliPlus/features/popular_precious/domain/repositories/popular_precious_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching popular precious items
class FetchPopularPreciousUseCase {
  const FetchPopularPreciousUseCase(this._repository);

  final PopularPreciousRepository _repository;

  Future<LoadingState<List<PopularPreciousItemEntity>>> call({
    required int page,
  }) {
    return _repository.fetchPopularPrecious(page: page);
  }
}
