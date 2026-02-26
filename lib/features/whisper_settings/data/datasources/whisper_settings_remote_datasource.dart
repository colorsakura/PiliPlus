import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show GetImSettingsReply, Setting;
import 'package:PiliPlus/features/whisper_settings/domain/entities/whisper_settings_entity.dart';

/// Data source interface for whisper settings operations
abstract class WhisperSettingsRemoteDataSource {
  /// Fetch whisper settings via gRPC API
  Future<LoadingState<GetImSettingsReply>> fetchSettings(WhisperSettingsParams params);

  /// Update whisper settings via gRPC API
  Future<LoadingState<void>> updateSettings(Map<int, Setting> settings);
}
