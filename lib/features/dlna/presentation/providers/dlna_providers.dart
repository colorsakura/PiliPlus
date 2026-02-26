import 'package:PiliPlus/features/dlna/data/datasources/dlna_remote_datasource.dart';
import 'package:PiliPlus/features/dlna/data/repositories/dlna_repository_impl.dart';
import 'package:PiliPlus/features/dlna/domain/repositories/dlna_repository.dart';
import 'package:PiliPlus/features/dlna/domain/usecases/cast_to_device.dart';
import 'package:PiliPlus/features/dlna/domain/usecases/search_dlna_devices.dart';
import 'package:PiliPlus/features/dlna/domain/usecases/stop_dlna_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// DLNA remote data source provider
final dlnaRemoteDataSourceProvider = Provider<DlnaRemoteDataSource>((ref) {
  return DlnaRemoteDataSourceImpl();
});

/// DLNA repository provider
final dlnaRepositoryProvider = Provider<DlnaRepository>((ref) {
  final remoteDataSource = ref.watch(dlnaRemoteDataSourceProvider);
  return DlnaRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Search DLNA devices use case provider
final searchDlnaDevicesUseCaseProvider = Provider<SearchDlnaDevices>((ref) {
  final repository = ref.watch(dlnaRepositoryProvider);
  return SearchDlnaDevices(repository);
});

/// Stop DLNA search use case provider
final stopDlnaSearchUseCaseProvider = Provider<StopDlnaSearch>((ref) {
  final repository = ref.watch(dlnaRepositoryProvider);
  return StopDlnaSearch(repository);
});

/// Cast to device use case provider
final castToDeviceUseCaseProvider = Provider<CastToDevice>((ref) {
  final repository = ref.watch(dlnaRepositoryProvider);
  return CastToDevice(repository);
});
