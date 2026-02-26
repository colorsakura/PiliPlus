import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/whisper/domain/repositories/whisper_repository.dart';
import 'package:PiliPlus/features/whisper/data/datasources/whisper_remote_datasource.dart';

/// Implementation of whisper repository
class WhisperRepositoryImpl implements WhisperRepository {
  final WhisperRemoteDataSource remoteDataSource;

  const WhisperRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<dynamic>> fetchSessions({
    dynamic offset,
  }) {
    return remoteDataSource.fetchSessions(offset: offset);
  }

  @override
  Future<LoadingState<dynamic>> fetchUnreadCounts() {
    return remoteDataSource.fetchUnreadCounts();
  }
}
