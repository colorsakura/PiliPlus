import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart' show GetImSettingsReply, Setting;
import 'package:PiliPlus/features/whisper_settings/domain/repositories/whisper_settings_repository.dart';
import 'package:PiliPlus/features/whisper_settings/data/datasources/whisper_settings_remote_datasource.dart';
import 'package:PiliPlus/features/whisper_settings/domain/entities/whisper_settings_entity.dart';

/// Implementation of whisper settings repository
class WhisperSettingsRepositoryImpl implements WhisperSettingsRepository {
  final WhisperSettingsRemoteDataSource remoteDataSource;

  const WhisperSettingsRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<GetImSettingsReply>> fetchSettings(WhisperSettingsParams params) {
    return remoteDataSource.fetchSettings(params);
  }

  @override
  Future<LoadingState<void>> updateSettings(Map<int, Setting> settings) {
    return remoteDataSource.updateSettings(settings);
  }
}
