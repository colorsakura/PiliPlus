import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show SessionPageType, SessionSecondaryReply;
import 'package:PiliPlus/features/whisper_secondary/domain/repositories/secondary_session_repository.dart';
import 'package:PiliPlus/features/whisper_secondary/domain/entities/secondary_session_params.dart';
import 'package:PiliPlus/features/whisper_secondary/data/datasources/secondary_session_remote_datasource.dart';

/// Implementation of secondary session repository
class SecondarySessionRepositoryImpl implements SecondarySessionRepository {
  final SecondarySessionRemoteDataSource remoteDataSource;

  const SecondarySessionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<SessionSecondaryReply>> fetchSecondarySessions(
    FetchSecondarySessionsParams params,
  ) {
    return remoteDataSource.fetchSecondarySessions(params);
  }
}
