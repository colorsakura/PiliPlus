import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/reply/reply_search_type.dart';
import 'package:PiliPlus/features/reply_search/domain/entities/reply_search_params_entity.dart';
import 'package:PiliPlus/features/reply_search/domain/repositories/reply_search_repository.dart';

/// Reply search remote data source interface
abstract class ReplySearchRemoteDataSource {
  /// Search reply items
  Future<LoadingState<dynamic>> searchReplies(ReplySearchParamsEntity params);
}

/// Reply search remote data source implementation using gRPC
class ReplySearchRemoteDataSourceImpl implements ReplySearchRemoteDataSource {
  @override
  Future<LoadingState<dynamic>> searchReplies(ReplySearchParamsEntity params) async {
    // Implementation delegates to ReplyGrpc
    // This is a placeholder to show where the data source would be
    throw UnimplementedError('Use ReplySearchRepositoryImpl directly');
  }
}
