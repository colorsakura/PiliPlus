/// 认证相关 API 常量
///
/// 定义所有登录、认证相关的 API 端点
library;

/// 认证相关 API 常量
abstract class AuthApiConstants {
  // ==================== 二维码登录 ====================
  /// 获取电视登录二维码
  static const String getTVCode =
      '/x/passport-tv-login/qrcode/auth_code';

  /// 二维码轮询
  static const String qrcodePoll =
      '/x/passport-tv-login/qrcode/poll';

  // ==================== 验证码 ====================
  /// 获取验证码
  static const String getCaptcha =
      '/x/passport-login/captcha?source=main_web';

  /// 获取公钥（密码加密用）
  static const String getWebKey =
      '/x/passport-login/web/key';

  // ==================== 短信登录 ====================
  /// APP发送短信验证码
  static const String appSmsCode =
      '/x/passport-login/sms/send';

  /// APP短信登录
  static const String logInByAppSms =
      '/x/passport-login/login/sms';

  /// 密码登录
  static const String loginByPwdApi =
      '/x/passport-login/oauth2/login';

  // ==================== 安全中心 ====================
  /// 获取安全中心信息
  static const String safeCenterGetInfo =
      '/x/safecenter/user/info';

  /// 预验证码
  static const String preCapture =
      '/x/safecenter/captcha/pre';

  /// 安全中心发送短信
  static const String safeCenterSmsCode =
      '/x/safecenter/common/sms/send';

  /// 安全中心短信验证
  static const String safeCenterSmsVerify =
      '/x/safecenter/login/tel/verify';

  /// OAuth2 Access Token
  static const String oauth2AccessToken =
      '/x/passport-login/oauth2/access_token';

  // ==================== 登出 ====================
  /// 退出登录
  static const String logout = '/login/exit/v2';

  // ==================== 登录设备 ====================
  /// 登录设备列表
  static const String loginDevices =
      '/x/safecenter/user_login_devices';

  // ==================== Web短信登录 ====================
  /// Web发送短信验证码
  static const String smsCode =
      '/x/passport-login/web/sms/send';

  /// Web密码登录
  static const String logInByWebPwd =
      '/x/passport-login/web/login';
}
