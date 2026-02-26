import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/features/group_panel/domain/repositories/group_panel_repository.dart';

/// Use case for fetching follow-up group tags
class FetchGroupTags {
  final GroupPanelRepository repository;

  const FetchGroupTags(this.repository);

  /// Execute the fetch operation
  ///
  /// Returns [Success] with list of group tags, or [Error] if failed
  Future<LoadingState<List<MemberTagItemModel>>> call() {
    return repository.fetchGroupTags();
  }
}
