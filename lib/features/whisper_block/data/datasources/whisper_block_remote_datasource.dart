import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart';
import 'package:PiliPlus/grpc/im.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Whisper block remote data source
class WhisperBlockRemoteDatasource {
  /// Get keyword blocking list from gRPC
  Future<LoadingState<KeywordBlockingListReply>> getKeywordBlockingList() async {
    try {
      final response = await ImGrpc.keywordBlockingList();
      return Success(response);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// Add keyword to blocking list
  Future<LoadingState<void>> addKeyword(String keyword) async {
    try {
      final response = await ImGrpc.keywordBlockingAdd(keyword);
      if (response.isSuccess) {
        return const Success(null);
      }
      return Error(response.errorMessage ?? '添加失败');
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// Delete keyword from blocking list
  Future<LoadingState<void>> deleteKeyword(String keyword) async {
    try {
      final response = await ImGrpc.keywordBlockingDelete(keyword);
      if (response.isSuccess) {
        return const Success(null);
      }
      return Error(response.errorMessage ?? '删除失败');
    } catch (e) {
      return Error(e.toString());
    }
  }
}
