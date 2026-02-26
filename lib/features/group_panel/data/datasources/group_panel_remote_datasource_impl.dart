import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/features/group_panel/data/datasources/group_panel_remote_datasource.dart';
import 'package:PiliPlus/features/group_panel/domain/entities/group_tag_entity.dart';
import 'package:PiliPlus/http/member.dart' as http;

/// Implementation of group panel remote data source using MemberHttp
class GroupPanelRemoteDataSourceImpl implements GroupPanelRemoteDataSource {
  const GroupPanelRemoteDataSourceImpl();

  @override
  Future<LoadingState<List<MemberTagItemModel>>> fetchGroupTags() {
    return http.MemberHttp.followUpTags();
  }

  @override
  Future<LoadingState<Null>> addUserToGroups(AddUserToGroupsParams params) {
    return http.MemberHttp.addUsers(
      params.mid,
      params.tagIds,
    );
  }
}
