import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/whisper/data/datasources/whisper_remote_datasource.dart';
import 'package:PiliPlus/grpc/im.dart' as grpc;

/// Implementation of whisper remote data source using ImGrpc
class WhisperRemoteDataSourceImpl implements WhisperRemoteDataSource {
  const WhisperRemoteDataSourceImpl();

  @override
  Future<LoadingState<dynamic>> fetchSessions({
    dynamic offset,
  }) {
    return grpc.ImGrpc.sessionMain(offset: offset);
  }

  @override
  Future<LoadingState<dynamic>> fetchUnreadCounts() {
    return grpc.ImGrpc.getTotalUnread(unreadType: 2);
  }
}
