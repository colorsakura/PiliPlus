import 'package:PiliPlus/features/dynamics_mention/domain/repositories/dyn_mention_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/group.dart';

/// Use case for searching users to mention
///
/// Searches for users that can be mentioned in a dynamic post.
class SearchMentions {
  final DynMentionRepository repository;

  SearchMentions(this.repository);

  /// Execute the search mentions use case
  ///
  /// [keyword] - Optional search keyword to filter users
  /// Returns a loading state with list of mention groups
  Future<LoadingState<List<MentionGroup>?>> call({String? keyword}) {
    return repository.searchMentions(keyword: keyword);
  }
}
