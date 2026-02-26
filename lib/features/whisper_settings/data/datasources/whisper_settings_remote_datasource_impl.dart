import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart' show GetImSettingsReply, Setting;
import 'package:PiliPlus/features/whisper_settings/data/datasources/whisper_settings_remote_datasource.dart';
import 'package:PiliPlus/features/whisper_settings/domain/entities/whisper_settings_entity.dart';
import 'package:PiliPlus/grpc/im.dart' as grpc;

/// Implementation of whisper settings remote data source using ImGrpc
class WhisperSettingsRemoteDataSourceImpl implements WhisperSettingsRemoteDataSource {
  const WhisperSettingsRemoteDataSourceImpl();

  @override
  Future<LoadingState<GetImSettingsReply>> fetchSettings(WhisperSettingsParams params) {
    return grpc.ImGrpc.getImSettings(type: params.imSettingType);
  }

  @override
  Future<LoadingState<void>> updateSettings(Map<int, Setting> settings) {
    return grpc.ImGrpc.setImSettings(settings: settings);
  }
}
