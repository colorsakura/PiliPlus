import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart';
import 'package:PiliPlus/grpc/im.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Whisper block remote data source
class WhisperBlockRemoteDatasource {
  /// Get keyword blocking list from gRPC
  Future<LoadingState<KeywordBlockingListReply>>
  getKeywordBlockingList() async {
    return ImGrpc.keywordBlockingList();
  }

  /// Add keyword to blocking list
  Future<LoadingState<void>> addKeyword(String keyword) async {
    final result = await ImGrpc.keywordBlockingAdd(keyword);
    return switch (result) {
      Loading() => result as LoadingState<void>,
      Error() => result as LoadingState<void>,
      Success() => const Success(null),
    };
  }

  /// Delete keyword from blocking list
  Future<LoadingState<void>> deleteKeyword(String keyword) async {
    final result = await ImGrpc.keywordBlockingDelete(keyword);
    return switch (result) {
      Loading() => result as LoadingState<void>,
      Error() => result as LoadingState<void>,
      Success() => const Success(null),
    };
  }
}
