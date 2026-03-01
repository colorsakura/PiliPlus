import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/whisper/domain/usecases/fetch_sessions.dart';
import 'package:PiliPlus/features/whisper/domain/usecases/fetch_unread_counts.dart';
import 'package:PiliPlus/features/whisper/data/repositories/whisper_repository_impl.dart';
import 'package:PiliPlus/features/whisper/data/datasources/whisper_remote_datasource_impl.dart';
import 'package:PiliPlus/http/loading_state.dart';

part 'whisper_session_controller.g.dart';

/// Provider for WhisperRemoteDataSource
final whisperRemoteDataSourceProvider = Provider<WhisperRemoteDataSourceImpl>((
  ref,
) {
  return const WhisperRemoteDataSourceImpl();
});

/// Provider for WhisperRepository
final whisperRepositoryProvider = Provider<WhisperRepositoryImpl>((ref) {
  final datasource = ref.watch(whisperRemoteDataSourceProvider);
  return WhisperRepositoryImpl(remoteDataSource: datasource);
});

/// Provider for FetchSessions use case
final fetchSessionsProvider = Provider<FetchSessions>((ref) {
  final repository = ref.watch(whisperRepositoryProvider);
  return FetchSessions(repository);
});

/// Provider for FetchUnreadCounts use case
final fetchUnreadCountsProvider = Provider<FetchUnreadCounts>((ref) {
  final repository = ref.watch(whisperRepositoryProvider);
  return FetchUnreadCounts(repository);
});

/// Whisper session state
class WhisperSessionState {
  final List sessions;
  final bool hasMore;
  final Map? offset;
  final bool isLoading;
  final String? errorMessage;

  const WhisperSessionState({
    this.sessions = const [],
    this.hasMore = false,
    this.offset,
    this.isLoading = false,
    this.errorMessage,
  });

  WhisperSessionState copyWith({
    List? sessions,
    bool? hasMore,
    Map? offset,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WhisperSessionState(
      sessions: sessions ?? this.sessions,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for managing whisper sessions
@riverpod
class WhisperSessionController extends _$WhisperSessionController {
  @override
  WhisperSessionState build() {
    // Fetch data on initialization
    fetchSessions();
    return const WhisperSessionState();
  }

  /// Fetch whisper sessions
  Future<void> fetchSessions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final fetchSessions = ref.read(fetchSessionsProvider);
      final result = await fetchSessions();

      switch (result) {
        case Success(:final response):
          state = state.copyWith(
            sessions: response.sessions,
            hasMore: response.paginationParams.hasMore,
            offset: response.paginationParams.offsets,
            isLoading: false,
          );
        case Error(:final errMsg):
          state = state.copyWith(
            isLoading: false,
            errorMessage: errMsg,
          );
        case Loading():
          break;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear sessions
  void clearSessions() {
    state = const WhisperSessionState();
  }
}
