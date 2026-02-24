import 'package:PiliPlus/features/dynamics_select_topic/data/datasources/topic_search_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_select_topic/domain/repositories/topic_search_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_pub_search/data.dart';

/// Implementation of topic search repository
///
/// Provides access to topic search data through remote data source.
class TopicSearchRepositoryImpl implements TopicSearchRepository {
  final TopicSearchRemoteDatasource remoteDatasource;

  TopicSearchRepositoryImpl({required this.remoteDatasource});

  @override
  Future<LoadingState<TopicPubSearchData>> searchTopics({
    String? keywords,
    int? pageNum,
  }) {
    return remoteDatasource.searchTopics(
      keywords: keywords,
      pageNum: pageNum,
    );
  }
}
