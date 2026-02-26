import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart'
    show SessionSecondaryReply;
import 'package:PiliPlus/features/whisper_secondary/domain/repositories/secondary_session_repository.dart';
import 'package:PiliPlus/features/whisper_secondary/domain/entities/secondary_session_params.dart';

/// Use case for fetching secondary session list
class FetchSecondarySessions {
  final SecondarySessionRepository repository;

  const FetchSecondarySessions(this.repository);

  /// Execute the fetch operation
  ///
  /// [params] contains sessionPageType and offset
  ///
  /// Returns [Success] with session list, or [Error] if failed
  Future<LoadingState<SessionSecondaryReply>> call(
    FetchSecondarySessionsParams params,
  ) {
    return repository.fetchSecondarySessions(params);
  }
}
