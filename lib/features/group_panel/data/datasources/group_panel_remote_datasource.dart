import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/features/group_panel/domain/entities/group_tag_entity.dart';

/// Data source interface for group panel operations
abstract class GroupPanelRemoteDataSource {
  /// Fetch all follow-up group tags via API
  Future<LoadingState<List<MemberTagItemModel>>> fetchGroupTags();

  /// Add user to specified groups via API
  Future<LoadingState<Null>> addUserToGroups(AddUserToGroupsParams params);
}
