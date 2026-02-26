import 'package:PiliPlus/models/space/space/card.dart';

/// 成员信息实体
///
/// 包含成员的基本信息
class MemberEntity {
  /// 成员ID
  final String? mid;

  /// 用户名
  final String? name;

  /// 头像
  final String? face;

  /// 签名
  final String? sign;

  /// 等级
  final int? level;

  /// 是否关注
  final int? isFollowed;

  /// 关注状态
  final int? relationStatus;

  /// 是否被禁言
  final int? silence;

  const MemberEntity({
    this.mid,
    this.name,
    this.face,
    this.sign,
    this.level,
    this.isFollowed,
    this.relationStatus,
    this.silence,
  });

  MemberEntity copyWith({
    String? mid,
    String? name,
    String? face,
    String? sign,
    int? level,
    int? isFollowed,
    int? relationStatus,
    int? silence,
  }) {
    return MemberEntity(
      mid: mid ?? this.mid,
      name: name ?? this.name,
      face: face ?? this.face,
      sign: sign ?? this.sign,
      level: level ?? this.level,
      isFollowed: isFollowed ?? this.isFollowed,
      relationStatus: relationStatus ?? this.relationStatus,
      silence: silence ?? this.silence,
    );
  }

  /// 从模型创建实体
  factory MemberEntity.fromCard(SpaceCard? card) {
    if (card == null) {
      return const MemberEntity();
    }
    return MemberEntity(
      mid: card.mid,
      name: card.name,
      face: card.face,
      sign: card.description,
      level: card.levelInfo?.currentLevel,
      isFollowed: card.relation?.isFollowed,
      relationStatus: card.relation?.status,
      silence: null, // SpaceCard没有silence字段
    );
  }

  /// 是否已关注
  bool get isFollow => isFollowed == 1;

  /// 是否被禁言
  bool get isSilenced => silence != null && silence! > 0;

  /// 获取mid的int值
  int? get midInt => mid != null ? int.tryParse(mid!) : null;
}
