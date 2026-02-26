import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/im/interfaces/v1.pb.dart' show RspSessionMsg;
import 'package:PiliPlus/features/whisper_detail/domain/entities/whisper_message_params.dart';
import 'package:PiliPlus/features/whisper_detail/domain/repositories/whisper_detail_repository.dart';
import 'package:PiliPlus/features/whisper_detail/data/datasources/whisper_detail_remote_datasource.dart';

/// Implementation of whisper detail repository
class WhisperDetailRepositoryImpl implements WhisperDetailRepository {
  final WhisperDetailRemoteDataSource remoteDataSource;

  const WhisperDetailRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<RspSessionMsg>> fetchSessionMessages(FetchSessionMessagesParams params) {
    return remoteDataSource.fetchSessionMessages(params);
  }

  @override
  Future<LoadingState<Map<String, dynamic>?>> sendMessage(SendMessageParams params) {
    return remoteDataSource.sendMessage(params);
  }

  @override
  Future<LoadingState<void>> ackSessionMessage(AckSessionMsgParams params) {
    return remoteDataSource.ackSessionMessage(params);
  }
}
