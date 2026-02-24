import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_topic/topic_item.dart';
import 'package:PiliPlus/features/fav/fav_topic/domain/repositories/fav_topic_repository.dart';
import 'package:PiliPlus/features/fav/fav_topic/data/datasources/fav_topic_remote_datasource.dart';

/// Repository implementation for favorite topics
class FavTopicRepositoryImpl implements FavTopicRepository {
  const FavTopicRepositoryImpl(this._remoteDatasource);

  final FavTopicRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<List<FavTopicItem>>> getFavTopics(int page) async {
    final result = await _remoteDatasource.getFavTopics(page: page);
    return switch (result) {
      Loading() => LoadingState.loading(),
      Success(:final response) => Success(response.toItemList()),
      Error(:final errMsg) => Error(errMsg),
    };
  }

  @override
  Future<LoadingState<void>> removeTopic(int id) {
    return _remoteDatasource.removeTopic(id);
  }
}
