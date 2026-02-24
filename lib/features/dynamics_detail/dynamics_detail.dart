// Dynamics detail feature
//
// Note: This page remains in lib/pages/dynamics_detail/
// because it depends heavily on CommonDynPageState and GetX infrastructure.
// The CommonDynController has been migrated to lib/core/controllers/.
//
// Re-export original implementation
export 'package:PiliPlus/pages/dynamics_detail/view.dart' show DynamicDetailPage;

// Domain layer (for future use)
export 'domain/entities/dyn_detail_state.dart';
export 'domain/repositories/dyn_detail_repository.dart';
export 'domain/usecases/get_dynamic_detail.dart';
export 'domain/usecases/set_pub_setting.dart';
export 'domain/usecases/set_reply_subject.dart';

// Data layer (for future use)
export 'data/datasources/dyn_detail_remote_datasource.dart';
export 'data/repositories/dyn_detail_repository_impl.dart';
