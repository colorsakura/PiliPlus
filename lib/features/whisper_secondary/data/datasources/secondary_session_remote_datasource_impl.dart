import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show SessionPageType, SessionSecondaryReply;
import 'package:PiliPlus/features/whisper_secondary/data/datasources/secondary_session_remote_datasource.dart';
import 'package:PiliPlus/features/whisper_secondary/domain/entities/secondary_session_params.dart';
import 'package:PiliPlus/grpc/im.dart' as grpc;

/// Implementation of secondary session remote data source using ImGrpc
class SecondarySessionRemoteDataSourceImpl implements SecondarySessionRemoteDataSource {
  const SecondarySessionRemoteDataSourceImpl();

  @override
  Future<LoadingState<SessionSecondaryReply>> fetchSecondarySessions(
    FetchSecondarySessionsParams params,
  ) {
    return grpc.ImGrpc.sessionSecondary(
      offset: params.offset,
      pageType: params.sessionPageType,
    );
  }
}
