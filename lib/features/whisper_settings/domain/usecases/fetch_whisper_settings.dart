import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show GetImSettingsReply;
import 'package:PiliPlus/features/whisper_settings/domain/repositories/whisper_settings_repository.dart';
import 'package:PiliPlus/features/whisper_settings/domain/entities/whisper_settings_entity.dart';

/// Use case for fetching whisper settings
class FetchWhisperSettings {
  final WhisperSettingsRepository repository;

  const FetchWhisperSettings(this.repository);

  /// Execute the fetch operation
  ///
  /// [params] contains the settings type
  ///
  /// Returns [Success] with settings response, or [Error] if failed
  Future<LoadingState<GetImSettingsReply>> call(WhisperSettingsParams params) {
    return repository.fetchSettings(params);
  }
}
