import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart' show Setting;
import 'package:PiliPlus/features/whisper_settings/domain/repositories/whisper_settings_repository.dart';

/// Use case for updating whisper settings
class UpdateWhisperSettings {
  final WhisperSettingsRepository repository;

  const UpdateWhisperSettings(this.repository);

  /// Execute the update operation
  ///
  /// [settings] is the map of settings to update
  ///
  /// Returns [Success] if update succeeded, [Error] otherwise
  Future<LoadingState<void>> call(Map<int, Setting> settings) {
    return repository.updateSettings(settings);
  }
}
