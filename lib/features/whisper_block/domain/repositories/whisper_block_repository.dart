import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Whisper block repository interface
abstract interface class WhisperBlockRepository {
  /// Get keyword blocking list
  Future<LoadingState<KeywordBlockingListReply>> getKeywordBlockingList();

  /// Add keyword to blocking list
  Future<LoadingState<void>> addKeyword(String keyword);

  /// Delete keyword from blocking list
  Future<LoadingState<void>> deleteKeyword(String keyword);
}
