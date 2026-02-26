import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show GetImSettingsReply, Setting;
import 'package:PiliPlus/features/whisper_settings/domain/entities/whisper_settings_entity.dart';

/// Repository interface for whisper settings operations
abstract class WhisperSettingsRepository {
  /// Fetch whisper settings
  ///
  /// [params] contains the settings type
  ///
  /// Returns [Success] with settings response, or [Error] if failed
  Future<LoadingState<GetImSettingsReply>> fetchSettings(WhisperSettingsParams params);

  /// Update whisper settings
  ///
  /// [settings] is the map of settings to update
  ///
  /// Returns [Success] if update succeeded, [Error] otherwise
  Future<LoadingState<void>> updateSettings(Map<int, Setting> settings);
}
