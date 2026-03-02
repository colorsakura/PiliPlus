// Domain exports
export 'domain/entities/topic_item_entity.dart';
export 'domain/repositories/dyn_topic_rcmd_repository.dart';
export 'domain/usecases/get_dyn_topic_rcmd.dart';

// Data exports
export 'data/datasources/dyn_topic_rcmd_remote_datasource.dart';
export 'data/repositories/dyn_topic_rcmd_repository_impl.dart';

// Presentation (ChangeNotifier - Legacy)
export 'presentation/providers/dyn_topic_rcmd_providers.dart' show dynTopicRcmdRepositoryProvider, getDynTopicRcmdUseCaseProvider;

// Presentation (Riverpod - New)
export 'presentation/providers/dyn_topic_rcmd_controller_v2.dart';
export 'presentation/pages/dyn_topic_rcmd_page.dart';
