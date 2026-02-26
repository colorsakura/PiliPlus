import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show SessionPageType, SessionSecondaryReply;
import 'package:PiliPlus/features/whisper_secondary/domain/entities/secondary_session_params.dart';

/// Data source interface for secondary session operations
abstract class SecondarySessionRemoteDataSource {
  /// Fetch secondary session list via gRPC API
  Future<LoadingState<SessionSecondaryReply>> fetchSecondarySessions(
    FetchSecondarySessionsParams params,
  );
}
