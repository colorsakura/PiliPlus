import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/features/group_panel/domain/entities/group_tag_entity.dart';
import 'package:PiliPlus/features/group_panel/domain/repositories/group_panel_repository.dart';
import 'package:PiliPlus/features/group_panel/data/datasources/group_panel_remote_datasource.dart';

/// Implementation of group panel repository
class GroupPanelRepositoryImpl implements GroupPanelRepository {
  final GroupPanelRemoteDataSource remoteDataSource;

  const GroupPanelRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<List<MemberTagItemModel>>> fetchGroupTags() {
    return remoteDataSource.fetchGroupTags();
  }

  @override
  Future<LoadingState<Null>> addUserToGroups(AddUserToGroupsParams params) {
    return remoteDataSource.addUserToGroups(params);
  }
}
