import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/reply_search/domain/entities/reply_search_params_entity.dart';

/// Reply search repository interface
abstract class ReplySearchRepository {
  /// Search reply items
  Future<LoadingState<dynamic>> searchReplies(ReplySearchParamsEntity params);
}
