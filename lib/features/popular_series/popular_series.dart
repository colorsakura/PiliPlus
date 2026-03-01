// Domain
export 'domain/repositories/popular_series_repository.dart';
export 'domain/usecases/get_popular_series_data.dart';

// Data
export 'data/datasources/popular_series_remote_datasource.dart';
export 'data/repositories/popular_series_repository_impl.dart';

// Presentation (ChangeNotifier - Legacy)
export 'presentation/providers/popular_series_controller.dart';
export 'presentation/providers/popular_series_providers.dart';
export 'presentation/pages/popular_series_page.dart';

// Presentation (Riverpod - New)
export 'presentation/providers/popular_series_list_controller.dart';
