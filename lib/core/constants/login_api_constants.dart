/// Login API 常量
///
/// 包含所有登录相关的 API 端点
library;

import 'package:PiliPlus/http/constants.dart';

abstract final class LoginApiConstants {
  // 验证码
  static const String getCaptcha =
      '${HttpString.passBaseUrl}/x/passport-login/captcha?source=main_web';

  // Web端短信验证码
  static const String smsCode =
      '${HttpString.passBaseUrl}/x/passport-login/web/sms/send';

  // Web端密码登录
  static const String logInByWebPwd =
      '${HttpString.passBaseUrl}/x/passport-login/web/login';

  // APP端短信验证码
  static const String appSmsCode =
      '${HttpString.passBaseUrl}/x/passport-login/sms/send';

  // APP端验证码登录
  static const String logInByAppSms =
      '${HttpString.passBaseUrl}/x/passport-login/login/sms';

  // APP端密码登录
  static const String loginByPwdApi =
      '${HttpString.passBaseUrl}/x/passport-login/oauth2/login';

  // 密码登录时风控验证：获取信息
  static const String safeCenterGetInfo =
      '${HttpString.passBaseUrl}/x/safecenter/user/info';

  // 验证绑定手机号前的人机验证
  static const String preCapture =
      '${HttpString.passBaseUrl}/x/safecenter/captcha/pre';

  // 密码登录时风控发送手机验证码
  static const String safeCenterSmsCode =
      '${HttpString.passBaseUrl}/x/safecenter/common/sms/send';

  // 密码登录时风控提交短信验证码
  static const String safeCenterSmsVerify =
      '${HttpString.passBaseUrl}/x/safecenter/login/tel/verify';

  // OAuth2 换取访问令牌
  static const String oauth2AccessToken =
      '${HttpString.passBaseUrl}/x/passport-login/oauth2/access_token';

  // 密码加密密钥
  static const String getWebKey =
      '${HttpString.passBaseUrl}/x/passport-login/web/key';

  // Cookie转access_key
  static const String qrcodeConfirm =
      '${HttpString.passBaseUrl}/x/passport-tv-login/h5/qrcode/confirm';

  // 申请二维码(TV端)
  static const String getTVCode =
      '${HttpString.passBaseUrl}/x/passport-tv-login/qrcode/auth_code';

  // 扫码登录（TV端）
  static const String qrcodePoll =
      '${HttpString.passBaseUrl}/x/passport-tv-login/qrcode/poll';

  // 退出登录
  static const String logout =
      '${HttpString.passBaseUrl}/login/exit/v2';

  // 登录设备列表
  static const String loginDevices =
      '${HttpString.passBaseUrl}/x/safecenter/user_login_devices';
}
