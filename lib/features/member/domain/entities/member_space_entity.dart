import 'package:PiliPlus/features/member/domain/entities/member_entity.dart';
import 'package:PiliPlus/features/member/domain/entities/member_tab_entity.dart';
import 'package:PiliPlus/models/space/space/live.dart';

/// 成员空间信息实体
///
/// 包含成员空间的所有信息
class MemberSpaceEntity {
  /// 成员信息
  final MemberEntity member;

  /// 标签页列表
  final List<MemberTabEntity> tabs;

  /// 是否有季度或系列
  final bool hasSeasonOrSeries;

  /// 直播信息
  final Live? live;

  /// 关系状态
  final int relation;

  const MemberSpaceEntity({
    required this.member,
    this.tabs = const [],
    this.hasSeasonOrSeries = false,
    this.live,
    this.relation = 0,
  });

  MemberSpaceEntity copyWith({
    MemberEntity? member,
    List<MemberTabEntity>? tabs,
    bool? hasSeasonOrSeries,
    Live? live,
    int? relation,
  }) {
    return MemberSpaceEntity(
      member: member ?? this.member,
      tabs: tabs ?? this.tabs,
      hasSeasonOrSeries: hasSeasonOrSeries ?? this.hasSeasonOrSeries,
      live: live ?? this.live,
      relation: relation ?? this.relation,
    );
  }

  /// 是否正在直播
  bool get isLive => live != null && live!.liveStatus == 1;

  /// 是否已关注
  bool get isFollow => relation != 0 && relation != 128;
}
