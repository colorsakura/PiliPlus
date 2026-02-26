import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show SessionPageType, SessionSecondaryReply;
import 'package:PiliPlus/features/whisper_secondary/domain/entities/secondary_session_params.dart';

/// Repository interface for secondary session operations
abstract class SecondarySessionRepository {
  /// Fetch secondary session list (at me, like me, etc.)
  ///
  /// [params] contains sessionPageType and offset
  ///
  /// Returns [Success] with session list, or [Error] if failed
  Future<LoadingState<SessionSecondaryReply>> fetchSecondarySessions(
    FetchSecondarySessionsParams params,
  );
}
