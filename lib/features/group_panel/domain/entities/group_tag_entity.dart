import 'package:PiliPlus/models/member/tags.dart';

/// Entity representing a group tag for following users
class GroupTagEntity {
  /// Tag ID
  final int tagId;

  /// Tag name
  final String name;

  /// Count of users in this tag
  final int count;

  /// Tooltip/description
  final String? tip;

  GroupTagEntity({
    required this.tagId,
    required this.name,
    required this.count,
    this.tip,
  });

  /// Create from MemberTagItemModel
  factory GroupTagEntity.fromModel(MemberTagItemModel model) {
    return GroupTagEntity(
      tagId: model.tagid ?? 0,
      name: model.name ?? '',
      count: model.count ?? 0,
      tip: model.tip,
    );
  }

  /// Check if this is the default group (tagId == 0)
  bool get isDefault => tagId == 0;

  @override
  String toString() => 'GroupTagEntity(tagId: $tagId, name: $name, count: $count)';
}

/// Entity representing parameters for adding user to groups
class AddUserToGroupsParams {
  /// User ID to add
  final String mid;

  /// Comma-separated tag IDs, '0' for default group
  final String tagIds;

  const AddUserToGroupsParams({
    required this.mid,
    required this.tagIds,
  });

  /// Check if adding to default group
  bool get isDefaultGroup => tagIds == '0';

  /// Get tag IDs as a list of integers
  List<int> get tagIdList {
    if (isDefaultGroup) return [0];
    return tagIds.split(',').map(int.parse).toList();
  }

  @override
  String toString() => 'AddUserToGroupsParams(mid: $mid, tagIds: $tagIds)';
}
