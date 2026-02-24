import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/features/follow_search/domain/repositories/follow_search_repository.dart';

/// Use case for searching followed users
class SearchFollowsUseCase {
  const SearchFollowsUseCase(this._repository);

  final FollowSearchRepository _repository;

  /// Search followed users by name
  Future<LoadingState<FollowData>> call({
    required int mid,
    required String name,
    required int page,
    int pageSize = 20,
  }) {
    return _repository.searchFollows(
      mid: mid,
      name: name,
      page: page,
      pageSize: pageSize,
    );
  }
}
