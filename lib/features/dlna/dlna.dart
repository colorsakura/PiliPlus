/// DLNA Feature
///
/// 提供DLNA投屏功能,支持搜索和连接DLNA设备
library;

// Domain
export 'domain/entities/dlna_device.dart' show DlnaDeviceEntity, DlnaSearchResultEntity;
export 'domain/repositories/dlna_repository.dart' show DlnaRepository;
export 'domain/usecases/search_dlna_devices.dart' show SearchDlnaDevices;
export 'domain/usecases/stop_dlna_search.dart' show StopDlnaSearch;
export 'domain/usecases/cast_to_device.dart' show CastToDevice;

// Data
export 'data/datasources/dlna_remote_datasource.dart' show DlnaRemoteDataSource, DlnaRemoteDataSourceImpl;
export 'data/repositories/dlna_repository_impl.dart' show DlnaRepositoryImpl;

// Presentation
export 'presentation/pages/dlna_page.dart' show DlnaPage;
export 'presentation/providers/dlna_providers.dart' show
  dlnaRemoteDataSourceProvider,
  dlnaRepositoryProvider,
  searchDlnaDevicesUseCaseProvider,
  stopDlnaSearchUseCaseProvider,
  castToDeviceUseCaseProvider;

