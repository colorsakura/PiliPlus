/// 短信验证码实体
///
/// 包含短信验证码相关信息
class SmsCodeEntity {
  /// 验证码密钥
  final String captchaKey;

  /// 发送时间戳
  final int timestamp;

  /// 过期时间（秒）
  final int expiresIn;

  const SmsCodeEntity({
    required this.captchaKey,
    required this.timestamp,
    this.expiresIn = 300, // 5分钟
  });

  SmsCodeEntity copyWith({
    String? captchaKey,
    int? timestamp,
    int? expiresIn,
  }) {
    return SmsCodeEntity(
      captchaKey: captchaKey ?? this.captchaKey,
      timestamp: timestamp ?? this.timestamp,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  /// 从Map创建实体
  factory SmsCodeEntity.fromMap(Map<String, dynamic> map) {
    return SmsCodeEntity(
      captchaKey: map['captcha_key'] as String,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 是否已过期
  bool get isExpired {
    final elapsed = DateTime.now().millisecondsSinceEpoch - timestamp;
    return elapsed > expiresIn * 1000;
  }
}
