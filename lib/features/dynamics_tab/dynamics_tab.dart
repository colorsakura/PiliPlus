// Dynamics tab feature
//
// Note: This page remains in lib/pages/dynamics_tab/
// because it depends heavily on CommonListController and GetX infrastructure.
// The CommonListController has been migrated to lib/core/controllers/.
//
// Re-export original implementation
export 'package:PiliPlus/pages/dynamics_tab/view.dart' show DynamicsTabPage;

// Domain layer (for future use)
export 'domain/entities/dyn_tab_state.dart';
export 'domain/repositories/dyn_tab_repository.dart';
export 'domain/usecases/fetch_follow_dynamics.dart';
export 'domain/usecases/remove_dynamic.dart';

// Data layer (for future use)
export 'data/datasources/dyn_tab_remote_datasource.dart';
export 'data/repositories/dyn_tab_repository_impl.dart';
