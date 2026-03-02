/// 风控验证信息实体
///
/// 包含风控验证所需的信息
class RiskVerifyInfoEntity {
  /// 账户信息
  final AccountInfo? accountInfo;

  /// 会员信息
  final MemberInfo? memberInfo;

  /// 是否绑定手机
  final bool bindTel;

  /// 是否绑定邮箱
  final bool bindMail;

  /// 是否需要手机验证
  final bool needTelVerify;

  /// 隐藏的手机号
  final String? hideTel;

  /// 隐藏的邮箱
  final String? hideMail;

  const RiskVerifyInfoEntity({
    this.accountInfo,
    this.memberInfo,
    this.bindTel = false,
    this.bindMail = false,
    this.needTelVerify = false,
    this.hideTel,
    this.hideMail,
  });

  RiskVerifyInfoEntity copyWith({
    AccountInfo? accountInfo,
    MemberInfo? memberInfo,
    bool? bindTel,
    bool? bindMail,
    bool? needTelVerify,
    String? hideTel,
    String? hideMail,
  }) {
    return RiskVerifyInfoEntity(
      accountInfo: accountInfo ?? this.accountInfo,
      memberInfo: memberInfo ?? this.memberInfo,
      bindTel: bindTel ?? this.bindTel,
      bindMail: bindMail ?? this.bindMail,
      needTelVerify: needTelVerify ?? this.needTelVerify,
      hideTel: hideTel ?? this.hideTel,
      hideMail: hideMail ?? this.hideMail,
    );
  }

  /// 从Map创建实体
  factory RiskVerifyInfoEntity.fromMap(Map<String, dynamic> map) {
    final accountInfo = map['account_info'] as Map<String, dynamic>?;
    final memberInfo = map['member_info'] as Map<String, dynamic>?;

    return RiskVerifyInfoEntity(
      accountInfo: accountInfo != null
          ? AccountInfo.fromMap(accountInfo)
          : null,
      memberInfo: memberInfo != null ? MemberInfo.fromMap(memberInfo) : null,
      bindTel: accountInfo?['tel_verify'] as bool? ?? false,
      bindMail: accountInfo?['mail_verify'] as bool? ?? false,
      needTelVerify: accountInfo?['tel_verify'] as bool? ?? false,
      hideTel: accountInfo?['hide_tel'] as String?,
      hideMail: accountInfo?['hide_mail'] as String?,
    );
  }
}

/// 账户信息
class AccountInfo {
  final String? hideTel;
  final String? hideMail;

  const AccountInfo({
    this.hideTel,
    this.hideMail,
  });

  factory AccountInfo.fromMap(Map<String, dynamic> map) {
    return AccountInfo(
      hideTel: map['hide_tel'] as String?,
      hideMail: map['hide_mail'] as String?,
    );
  }
}

/// 会员信息
class MemberInfo {
  final String? nickname;
  final String? face;

  const MemberInfo({
    this.nickname,
    this.face,
  });

  factory MemberInfo.fromMap(Map<String, dynamic> map) {
    return MemberInfo(
      nickname: map['nickname'] as String?,
      face: map['face'] as String?,
    );
  }
}
