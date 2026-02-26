/// 登录结果实体
///
/// 包含登录操作的所有可能结果
class LoginResultEntity {
  /// 是否登录成功
  final bool isSuccess;

  /// 错误代码
  final int? errorCode;

  /// 错误消息
  final String? errorMessage;

  /// 访问令牌信息
  final TokenInfo? tokenInfo;

  /// Cookie信息
  final List<CookieInfo>? cookies;

  /// 是否需要风控验证
  final bool needRiskVerify;

  /// 风控验证URL
  final String? riskVerifyUrl;

  const LoginResultEntity({
    required this.isSuccess,
    this.errorCode,
    this.errorMessage,
    this.tokenInfo,
    this.cookies,
    this.needRiskVerify = false,
    this.riskVerifyUrl,
  });

  LoginResultEntity copyWith({
    bool? isSuccess,
    int? errorCode,
    String? errorMessage,
    TokenInfo? tokenInfo,
    List<CookieInfo>? cookies,
    bool? needRiskVerify,
    String? riskVerifyUrl,
  }) {
    return LoginResultEntity(
      isSuccess: isSuccess ?? this.isSuccess,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      tokenInfo: tokenInfo ?? this.tokenInfo,
      cookies: cookies ?? this.cookies,
      needRiskVerify: needRiskVerify ?? this.needRiskVerify,
      riskVerifyUrl: riskVerifyUrl ?? this.riskVerifyUrl,
    );
  }

  /// 创建成功结果
  factory LoginResultEntity.success({
    required TokenInfo tokenInfo,
    required List<CookieInfo> cookies,
  }) {
    return LoginResultEntity(
      isSuccess: true,
      tokenInfo: tokenInfo,
      cookies: cookies,
    );
  }

  /// 创建失败结果
  factory LoginResultEntity.failure({
    int? errorCode,
    String? errorMessage,
  }) {
    return LoginResultEntity(
      isSuccess: false,
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }

  /// 创建需要风控验证的结果
  factory LoginResultEntity.needRiskVerify({
    required String verifyUrl,
  }) {
    return LoginResultEntity(
      isSuccess: false,
      needRiskVerify: true,
      riskVerifyUrl: verifyUrl,
    );
  }
}

/// 访问令牌信息
class TokenInfo {
  /// 访问令牌
  final String accessToken;

  /// 刷新令牌
  final String? refreshToken;

  const TokenInfo({
    required this.accessToken,
    this.refreshToken,
  });

  TokenInfo copyWith({
    String? accessToken,
    String? refreshToken,
  }) {
    return TokenInfo(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  factory TokenInfo.fromMap(Map<String, dynamic> map) {
    return TokenInfo(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String?,
    );
  }
}

/// Cookie信息
class CookieInfo {
  /// Cookie名称
  final String name;

  /// Cookie值
  final String value;

  const CookieInfo({
    required this.name,
    required this.value,
  });

  CookieInfo copyWith({
    String? name,
    String? value,
  }) {
    return CookieInfo(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  factory CookieInfo.fromMap(Map<String, dynamic> map) {
    return CookieInfo(
      name: map['name'] as String,
      value: map['value'] as String,
    );
  }
}
