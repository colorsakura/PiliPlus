import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/features/group_panel/domain/entities/group_tag_entity.dart';

/// Repository interface for group panel operations
abstract class GroupPanelRepository {
  /// Fetch all follow-up group tags
  ///
  /// Returns [Success] with list of tags, or [Error] if failed
  Future<LoadingState<List<MemberTagItemModel>>> fetchGroupTags();

  /// Add user to specified groups
  ///
  /// [params] contains user ID and tag IDs
  ///
  /// Returns [Success] if operation succeeded, [Error] otherwise
  Future<LoadingState<Null>> addUserToGroups(AddUserToGroupsParams params);
}
