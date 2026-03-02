// Domain exports
export 'domain/entities/member_entity.dart';
export 'domain/entities/member_space_entity.dart';
export 'domain/entities/member_tab_entity.dart';
export 'domain/repositories/member_repository.dart';
export 'domain/usecases/follow_member.dart';
export 'domain/usecases/get_member_space.dart';

// Data exports
export 'data/datasources/member_api_datasource.dart';
export 'data/repositories/member_repository_impl.dart';

// Presentation (ChangeNotifier - Legacy)
export 'presentation/providers/member_providers.dart' show memberRemoteDataSourceProvider, memberRepositoryProvider, getMemberSpaceUseCaseProvider, followMemberUseCaseProvider;

// Presentation (Riverpod - New)
export 'presentation/providers/member_controller_v2.dart';

// Pages
export 'presentation/pages/member_page.dart';
