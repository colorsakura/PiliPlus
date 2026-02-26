import 'package:PiliPlus/models/user/stat.dart';

/// 用户统计信息实体
///
/// 包含用户的统计数据
class UserStatEntity {
  /// 动态数
  final int? dynamicCount;

  /// 关注数
  final int? followingCount;

  /// 粉丝数
  final int? followerCount;

  const UserStatEntity({
    this.dynamicCount,
    this.followingCount,
    this.followerCount,
  });

  UserStatEntity copyWith({
    int? dynamicCount,
    int? followingCount,
    int? followerCount,
  }) {
    return UserStatEntity(
      dynamicCount: dynamicCount ?? this.dynamicCount,
      followingCount: followingCount ?? this.followingCount,
      followerCount: followerCount ?? this.followerCount,
    );
  }

  /// 从模型创建实体
  factory UserStatEntity.fromModel(UserStat model) {
    return UserStatEntity(
      dynamicCount: model.dynamicCount,
      followingCount: model.following,
      followerCount: model.follower,
    );
  }

  /// 创建默认空实体
  factory UserStatEntity.empty() {
    return const UserStatEntity(
      dynamicCount: 0,
      followingCount: 0,
      followerCount: 0,
    );
  }

  /// 格式化数字显示
  String formatCount(int? count) {
    if (count == null) return '0';
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }

  /// 格式化的动态数
  String get formattedDynamicCount => formatCount(dynamicCount);

  /// 格式化的关注数
  String get formattedFollowingCount => formatCount(followingCount);

  /// 格式化的粉丝数
  String get formattedFollowerCount => formatCount(followerCount);
}
