import 'package:PiliPlus/features/member/domain/entities/member_space_entity.dart';

/// 成员仓库接口
///
/// 定义所有成员相关的数据操作
abstract interface class MemberRepository {
  /// 获取成员空间信息
  ///
  /// [mid] 成员ID
  /// [fromViewAid] 来源视频ID（可选）
  Future<MemberSpaceEntity> getMemberSpace({
    required int mid,
    String? fromViewAid,
  });

  /// 关注成员
  ///
  /// [mid] 成员ID
  /// [follow] 是否关注
  Future<void> followMember({
    required int mid,
    required bool follow,
  });

  /// 拉黑/取消拉黑成员
  ///
  /// [mid] 成员ID
  /// [block] 是否拉黑
  Future<void> blockMember({
    required int mid,
    required bool block,
  });

  /// 举报成员
  ///
  /// [mid] 成员ID
  /// [reason] 举报原因
  /// [reasonV2] 举报原因V2
  Future<void> reportMember({
    required int mid,
    String? reason,
    int? reasonV2,
  });
}
