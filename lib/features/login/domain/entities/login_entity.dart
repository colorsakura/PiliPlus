/// 登录实体
///
/// 表示用户登录成功的领域对象
class LoginEntity {
  /// 用户 ID
  final String userId;

  /// 访问令牌
  final String accessToken;

  /// 刷新令牌
  final String refreshToken;

  /// 过期时间（秒）
  final int expiresIn;

  const LoginEntity({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  /// 是否已过期
  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 > expiresIn;
  }

  /// 复制并修改部分属性
  LoginEntity copyWith({
    String? userId,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
  }) {
    return LoginEntity(
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginEntity &&
        other.userId == userId &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresIn == expiresIn;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode ^
        expiresIn.hashCode;
  }
}
