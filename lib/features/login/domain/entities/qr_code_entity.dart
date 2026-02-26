/// 二维码登录实体
///
/// 包含二维码登录所需的所有信息
class QrCodeEntity {
  /// 授权码
  final String authCode;

  /// 二维码URL
  final String url;

  /// 剩余有效时间（秒）
  final int expiresIn;

  const QrCodeEntity({
    required this.authCode,
    required this.url,
    this.expiresIn = 180,
  });

  QrCodeEntity copyWith({
    String? authCode,
    String? url,
    int? expiresIn,
  }) {
    return QrCodeEntity(
      authCode: authCode ?? this.authCode,
      url: url ?? this.url,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  /// 从Map创建实体
  factory QrCodeEntity.fromMap(Map<String, dynamic> map) {
    return QrCodeEntity(
      authCode: map['auth_code'] as String,
      url: map['url'] as String,
    );
  }

  /// 是否已过期
  bool get isExpired => expiresIn <= 0;
}
