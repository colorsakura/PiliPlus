import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/whisper_link_setting/data/datasources/whisper_link_setting_remote_datasource.dart';
import 'package:PiliPlus/features/whisper_link_setting/data/repositories/whisper_link_setting_repository_impl.dart';
import 'package:PiliPlus/features/whisper_link_setting/domain/repositories/whisper_link_setting_repository.dart';
import 'package:PiliPlus/features/whisper_link_setting/presentation/providers/whisper_link_setting_controller.dart';

// Remote Datasource Provider
final whisperLinkSettingRemoteDatasourceProvider =
    Provider<WhisperLinkSettingRemoteDatasource>((ref) {
  return const WhisperLinkSettingRemoteDatasource();
});

// Repository Provider
final whisperLinkSettingRepositoryProvider =
    Provider<WhisperLinkSettingRepository>((ref) {
  final datasource = ref.watch(whisperLinkSettingRemoteDatasourceProvider);
  return WhisperLinkSettingRepositoryImpl(datasource);
});

// Controller Provider - uses Provider.family for different talker UIDs
final whisperLinkSettingControllerProvider =
    Provider.family<WhisperLinkSettingController, int>((ref, talkerUid) {
  return WhisperLinkSettingController(
    talkerUid: talkerUid,
    repository: ref.watch(whisperLinkSettingRepositoryProvider),
  )..initialize();
});
