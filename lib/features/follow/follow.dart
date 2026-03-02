// Domain exports
export 'domain/repositories/follow_repository.dart';
export 'domain/usecases/create_follow_tag_usecase.dart';
export 'domain/usecases/delete_follow_tag_usecase.dart';
export 'domain/usecases/get_follow_up_tags_usecase.dart';
export 'domain/usecases/get_member_card_info_usecase.dart';
export 'domain/usecases/update_follow_tag_usecase.dart';

// Data exports
export 'data/datasources/follow_remote_datasource.dart';
export 'data/repositories/follow_repository_impl.dart';

// Presentation (ChangeNotifier - Legacy)
export 'presentation/providers/follow_providers.dart' show followRemoteDatasourceProvider, followRepositoryProvider, getMemberCardInfoUseCaseProvider, getFollowUpTagsUseCaseProvider, createFollowTagUseCaseProvider, updateFollowTagUseCaseProvider, deleteFollowTagUseCaseProvider, FollowParams;
export 'presentation/providers/follow_state.dart';

// Presentation (Riverpod - New)
export 'presentation/providers/follow_controller_v2.dart';

// Pages
export 'presentation/pages/follow_page_v2.dart';
