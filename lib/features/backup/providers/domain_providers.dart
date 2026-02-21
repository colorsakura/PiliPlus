// Export use case classes for type access
export 'package:PiliPlus/features/backup/domain/usecases/backup_settings_usecase.dart';
export 'package:PiliPlus/features/backup/domain/usecases/get_webdav_config_usecase.dart';
export 'package:PiliPlus/features/backup/domain/usecases/initialize_webdav_usecase.dart';
export 'package:PiliPlus/features/backup/domain/usecases/restore_settings_usecase.dart';
export 'package:PiliPlus/features/backup/domain/usecases/save_webdav_config_usecase.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:PiliPlus/features/backup/data/datasources/backup_config_local_datasource.dart';
import 'package:PiliPlus/features/backup/data/datasources/settings_local_datasource.dart';
import 'package:PiliPlus/features/backup/data/datasources/webdav_remote_datasource.dart';
import 'package:PiliPlus/features/backup/data/repositories/backup_config_repository_impl.dart';
import 'package:PiliPlus/features/backup/data/repositories/settings_repository_impl.dart';
import 'package:PiliPlus/features/backup/data/repositories/webdav_repository_impl.dart';
import 'package:PiliPlus/features/backup/domain/repositories/backup_config_repository.dart';
import 'package:PiliPlus/features/backup/domain/repositories/settings_repository.dart';
import 'package:PiliPlus/features/backup/domain/repositories/webdav_repository.dart';
import 'package:PiliPlus/features/backup/domain/usecases/backup_settings_usecase.dart';
import 'package:PiliPlus/features/backup/domain/usecases/get_webdav_config_usecase.dart';
import 'package:PiliPlus/features/backup/domain/usecases/initialize_webdav_usecase.dart';
import 'package:PiliPlus/features/backup/domain/usecases/restore_settings_usecase.dart';
import 'package:PiliPlus/features/backup/domain/usecases/save_webdav_config_usecase.dart';

// ============ Data Sources Providers ============

final webDavRemoteDataSourceProvider = Provider<WebDavRemoteDataSource>((ref) {
  return WebDavRemoteDataSourceImpl.instance;
});

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  return SettingsLocalDataSourceImpl();
});

final backupConfigLocalDataSourceProvider =
    Provider<BackupConfigLocalDataSource>((ref) {
      return BackupConfigLocalDataSourceImpl();
    });

// ============ Repository Providers ============

final webDavRepositoryProvider = Provider<WebDavRepository>((ref) {
  return WebDavRepositoryImpl(ref.watch(webDavRemoteDataSourceProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider));
});

final backupConfigRepositoryProvider = Provider<BackupConfigRepository>((ref) {
  return BackupConfigRepositoryImpl(
    ref.watch(backupConfigLocalDataSourceProvider),
  );
});

// ============ Use Case Providers ============

final initializeWebDavUseCaseProvider = Provider<InitializeWebDavUseCase>((ref) {
  return InitializeWebDavUseCase(ref.watch(webDavRepositoryProvider));
});

final backupSettingsUseCaseProvider = Provider<BackupSettingsUseCase>((ref) {
  return BackupSettingsUseCase(
    ref.watch(settingsRepositoryProvider),
    ref.watch(webDavRepositoryProvider),
  );
});

final restoreSettingsUseCaseProvider = Provider<RestoreSettingsUseCase>((ref) {
  return RestoreSettingsUseCase(
    ref.watch(settingsRepositoryProvider),
    ref.watch(webDavRepositoryProvider),
  );
});

final getWebDavConfigUseCaseProvider = Provider<GetWebDavConfigUseCase>((ref) {
  return GetWebDavConfigUseCase(ref.watch(backupConfigRepositoryProvider));
});

final saveWebDavConfigUseCaseProvider = Provider<SaveWebDavConfigUseCase>((ref) {
  return SaveWebDavConfigUseCase(ref.watch(backupConfigRepositoryProvider));
});
