import 'package:PiliPlus/features/dynamics_select_topic/data/datasources/topic_search_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_select_topic/data/repositories/topic_search_repository_impl.dart';
import 'package:PiliPlus/features/dynamics_select_topic/domain/repositories/topic_search_repository.dart';
import 'package:PiliPlus/features/dynamics_select_topic/domain/usecases/search_topics.dart';
import 'package:PiliPlus/features/dynamics_select_topic/presentation/providers/topic_search_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the topic search remote data source
final topicSearchRemoteDatasourceProvider =
    Provider<TopicSearchRemoteDatasource>((ref) {
      return TopicSearchRemoteDatasource();
    });

/// Provider for the topic search repository
final topicSearchRepositoryProvider = Provider<TopicSearchRepository>((ref) {
  final remoteDatasource = ref.watch(topicSearchRemoteDatasourceProvider);
  return TopicSearchRepositoryImpl(remoteDatasource: remoteDatasource);
});

/// Provider for the search topics use case
final searchTopicsProvider = Provider<SearchTopics>((ref) {
  final repository = ref.watch(topicSearchRepositoryProvider);
  return SearchTopics(repository);
});

/// Provider for the topic search controller
final topicSearchControllerProvider = Provider<TopicSearchController>((ref) {
  final searchTopics = ref.watch(searchTopicsProvider);
  final controller = TopicSearchController(searchTopics);

  // Initial search on creation
  controller.searchTopics();

  return controller;
});
