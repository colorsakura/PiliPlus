import 'package:PiliPlus/models/user/info.dart';

/// 用户信息实体
///
/// 包含用户的基本信息
class UserInfoEntity {
  /// 用户mid
  final int? mid;

  /// 用户名
  final String? uname;

  /// 头像URL
  final String? face;

  /// 等级
  final int? level;

  /// 会员状态
  final int? vipStatus;

  /// 会员类型
  final int? vipType;

  /// 会员到期时间
  final int? vipDueDate;

  /// 是否登录
  final bool isLogin;

  const UserInfoEntity({
    this.mid,
    this.uname,
    this.face,
    this.level,
    this.vipStatus,
    this.vipType,
    this.vipDueDate,
    this.isLogin = false,
  });

  UserInfoEntity copyWith({
    int? mid,
    String? uname,
    String? face,
    int? level,
    int? vipStatus,
    int? vipType,
    int? vipDueDate,
    bool? isLogin,
  }) {
    return UserInfoEntity(
      mid: mid ?? this.mid,
      uname: uname ?? this.uname,
      face: face ?? this.face,
      level: level ?? this.level,
      vipStatus: vipStatus ?? this.vipStatus,
      vipType: vipType ?? this.vipType,
      vipDueDate: vipDueDate ?? this.vipDueDate,
      isLogin: isLogin ?? this.isLogin,
    );
  }

  /// 从模型创建实体
  factory UserInfoEntity.fromModel(UserInfoData model) {
    return UserInfoEntity(
      mid: model.mid,
      uname: model.uname,
      face: model.face,
      level: model.levelInfo?.currentLevel,
      vipStatus: model.vipStatus,
      vipType: model.vipType,
      vipDueDate: model.vipDueDate,
      isLogin: model.isLogin ?? false,
    );
  }

  /// 创建默认空实体
  factory UserInfoEntity.empty() {
    return const UserInfoEntity();
  }

  /// 是否为空
  bool get isEmpty => mid == null || mid == 0;

  /// 是否有大会员
  bool get isVIP => vipStatus == 1;
}
