import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/reply_search/domain/entities/reply_search_params_entity.dart';
import 'package:PiliPlus/features/reply_search/domain/repositories/reply_search_repository.dart';

/// Search replies use case
class SearchReplies {
  final ReplySearchRepository repository;

  const SearchReplies(this.repository);

  Future<LoadingState<dynamic>> call(ReplySearchParamsEntity params) {
    return repository.searchReplies(params);
  }
}
