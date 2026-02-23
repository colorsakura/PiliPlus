import 'package:PiliPlus/features/about/data/datasources/about_local_datasource.dart';
import 'package:PiliPlus/features/about/data/repositories/about_repository_impl.dart';
import 'package:PiliPlus/features/about/domain/repositories/about_repository.dart';
import 'package:PiliPlus/features/about/domain/usecases/clear_cache.dart';
import 'package:PiliPlus/features/about/domain/usecases/export_settings.dart';
import 'package:PiliPlus/features/about/domain/usecases/get_app_info.dart';
import 'package:PiliPlus/features/about/domain/usecases/get_cache_info.dart';
import 'package:PiliPlus/features/about/domain/usecases/import_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// About本地数据源Provider
final aboutLocalDataSourceProvider = Provider<AboutLocalDataSource>((ref) {
  return AboutLocalDataSource();
});

/// About仓库Provider
final aboutRepositoryProvider = Provider<AboutRepository>((ref) {
  final localDataSource = ref.watch(aboutLocalDataSourceProvider);
  return AboutRepositoryImpl(
    localDataSource: localDataSource,
  );
});

/// 获取应用信息用例Provider
final getAppInfoUseCaseProvider = Provider<GetAppInfoUseCase>((ref) {
  final repository = ref.watch(aboutRepositoryProvider);
  return GetAppInfoUseCase(repository);
});

/// 获取缓存信息用例Provider
final getCacheInfoUseCaseProvider = Provider<GetCacheInfoUseCase>((ref) {
  final repository = ref.watch(aboutRepositoryProvider);
  return GetCacheInfoUseCase(repository);
});

/// 清除缓存用例Provider
final clearCacheUseCaseProvider = Provider<ClearCacheUseCase>((ref) {
  final repository = ref.watch(aboutRepositoryProvider);
  return ClearCacheUseCase(repository);
});

/// 导出设置用例Provider
final exportSettingsUseCaseProvider = Provider<ExportSettingsUseCase>((ref) {
  final repository = ref.watch(aboutRepositoryProvider);
  return ExportSettingsUseCase(repository);
});

/// 导入设置用例Provider
final importSettingsUseCaseProvider = Provider<ImportSettingsUseCase>((ref) {
  final repository = ref.watch(aboutRepositoryProvider);
  return ImportSettingsUseCase(repository);
});
