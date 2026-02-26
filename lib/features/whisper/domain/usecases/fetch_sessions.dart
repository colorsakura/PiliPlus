import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/whisper/domain/repositories/whisper_repository.dart';

/// Use case for fetching whisper sessions
class FetchSessions {
  final WhisperRepository repository;

  const FetchSessions(this.repository);

  /// Execute the fetch operation
  ///
  /// [offset] is pagination offset from previous result
  ///
  /// Returns [Success] with session list, or [Error] if failed
  Future<LoadingState<dynamic>> call({dynamic offset}) {
    return repository.fetchSessions(offset: offset);
  }
}
