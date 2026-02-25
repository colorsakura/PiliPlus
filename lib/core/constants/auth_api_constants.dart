/// 认证相关 API 常量
///
/// 定义所有登录、认证相关的 API 端点
library;

/// 认证相关 API 常量
abstract class AuthApiConstants {
  // ==================== 二维码登录 ====================
  /// 获取电视登录二维码
  static const String getTVCode = 'https://passport.bilibili.com/x/passport-tv-login/qrcode/auth_code';

  /// 二维码轮询
  static const String qrcodePoll = 'https://passport.bilibili.com/x/passport-tv-login/qrcode/poll';

  /// Web 登录二维码
  static const String getQrCode = 'https://passport.bilibili.com/x/passport-login/web/qrcode/generate';

  /// Web 登录二维码轮询
  static const String qrcodeLoginPoll = 'https://passport.bilibili.com/x/passport-login/web/qrcode/poll';

  // ==================== 验证码 ====================
  /// 获取验证码
  static const String getCaptcha = 'https://passport.bilibili.com/x/passport-login/captcha?source=main_web';

  // ==================== 短信登录 ====================
  /// 发送短信验证码
  static const String smsCode = 'https://passport.bilibili.com/x/passport-login/web/sms/send';

  /// 短信登录/注册
  static const String loginBySms = 'https://passport.bilibili.com/x/passport-login/web/login/sms';

  /// 密码登录
  static const String loginByPwdApi = 'https://passport.bilibili.com/x/passport-login/web/login';

  // ==================== 登出 ====================
  /// 退出登录
  static const String logout = 'https://passport.bilibili.com/login/exit/v2';

  // ==================== 用户信息 ====================
  /// 导航栏用户信息
  static const String userInfo = '/x/web-interface/nav';

  /// 用户统计信息
  static const String userStatOwner = '/x/web-interface/nav/stat';

  /// 我的个人信息
  static const String myInfo = '/x/space/acc/info';

  /// 用户硬币余额
  static const String userCoin = '/x/web-interface/coin/tick/v2';

  // ==================== 登录设备 ====================
  /// 登录设备列表
  static const String loginDevices = 'https://account.bilibili.com/index/pc';

  /// 登录日志
  static const String loginLog = '/x/member/web/login/log';
}
