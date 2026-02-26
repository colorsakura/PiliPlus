import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/whisper/domain/repositories/whisper_repository.dart';

/// Use case for fetching unread message counts
class FetchUnreadCounts {
  final WhisperRepository repository;

  const FetchUnreadCounts(this.repository);

  /// Execute the fetch operation
  ///
  /// Returns [Success] with unread counts data, or [Error] if failed
  Future<LoadingState<dynamic>> call() {
    return repository.fetchUnreadCounts();
  }
}
