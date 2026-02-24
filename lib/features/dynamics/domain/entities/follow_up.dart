import 'package:PiliPlus/models/dynamics/up.dart';

/// User (UP) information in the follow-up list.
class UpItemEntity {
  const UpItemEntity({
    required this.mid,
    this.face,
    this.name,
    this.hasUpdate,
  });

  factory UpItemEntity.fromModel(UpItem model) {
    return UpItemEntity(
      mid: model.mid,
      face: model.face,
      name: model.uname,
      hasUpdate: model.hasUpdate,
    );
  }

  final int mid;
  final String? face;
  final String? name;
  final bool? hasUpdate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UpItemEntity && mid == other.mid;

  @override
  int get hashCode => mid.hashCode;
}

/// Live user item in the follow-up list.
class LiveUserItemEntity extends UpItemEntity {
  const LiveUserItemEntity({
    required super.mid,
    this.isReserveRecall,
    this.jumpUrl,
    this.roomId,
    this.title,
    super.face,
    super.name,
    super.hasUpdate,
  });

  final bool? isReserveRecall;
  final String? jumpUrl;
  final int? roomId;
  final String? title;
}

/// Live users group information.
class LiveUsersEntity {
  const LiveUsersEntity({
    this.count,
    this.group,
    this.items,
  });

  final int? count;
  final String? group;
  final List<LiveUserItemEntity>? items;
}

/// Follow-up model containing UP users information.
class FollowUpEntity {
  const FollowUpEntity({
    this.liveUsers,
    required this.upList,
    this.hasMore,
    this.offset,
  });

  final LiveUsersEntity? liveUsers;
  final List<UpItemEntity> upList;
  final bool? hasMore;
  final String? offset;
}
