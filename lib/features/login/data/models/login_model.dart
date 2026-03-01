import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';

/// 登录数据模型
///
/// 来自 API 的 DTO 对象
class LoginModel {
  final String userId;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const LoginModel({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  /// 从 JSON 创建
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      userId: json['user_id'] as String? ?? json['mid'] as String? ?? '',
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresIn: json['expires_in'] as int? ?? 0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }

  /// 转换为 Entity
  LoginEntity toEntity() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return LoginEntity(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: now + expiresIn,
    );
  }
}
