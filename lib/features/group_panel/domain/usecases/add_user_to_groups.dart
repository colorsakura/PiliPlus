import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/group_panel/domain/entities/group_tag_entity.dart';
import 'package:PiliPlus/features/group_panel/domain/repositories/group_panel_repository.dart';

/// Use case for adding a user to follow groups
class AddUserToGroups {
  final GroupPanelRepository repository;

  const AddUserToGroups(this.repository);

  /// Execute the add operation
  ///
  /// [params] contains user ID and tag IDs
  ///
  /// Returns [Success] if operation succeeded, [Error] otherwise
  Future<LoadingState<Null>> call(AddUserToGroupsParams params) {
    return repository.addUserToGroups(params);
  }
}
