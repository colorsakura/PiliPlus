import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/login_result_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/qr_code_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/risk_verify_info_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/sms_code_entity.dart';
import 'package:PiliPlus/models/login/model.dart';

/// 登录仓库接口
///
/// 定义所有登录相关的数据操作
abstract interface class LoginRepository {
  /// 获取电视扫码登录二维码
  Future<QrCodeEntity> getQRCode();

  /// 轮询二维码扫码状态
  ///
  /// [authCode] 二维码授权码
  ///
  /// 返回结果包含：
  /// - status: 是否扫码成功
  /// - code: 状态码
  /// - data: 登录数据（如果成功）
  /// - msg: 消息
  Future<Map<String, dynamic>> pollQRCode(String authCode);

  /// 密码登录
  ///
  /// [username] 用户名
  /// [password] 密码
  /// [key] RSA公钥
  /// [salt] 密码盐值
  /// [geeChallenge] 极验挑战参数
  /// [geeSeccode] 极验seccode参数
  /// [geeValidate] 极验validate参数
  /// [recaptchaToken] reCAPTCHA令牌
  Future<LoginResultEntity> loginByPassword({
    required String username,
    required String password,
    required String key,
    required String salt,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  });

  /// 发送短信验证码
  ///
  /// [cid] 国家代码
  /// [tel] 手机号
  /// [geeChallenge] 极验挑战参数
  /// [geeSeccode] 极验seccode参数
  /// [geeValidate] 极验validate参数
  /// [recaptchaToken] reCAPTCHA令牌
  Future<SmsCodeEntity> sendSmsCode({
    required Object cid,
    required String tel,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  });

  /// 短信验证码登录
  ///
  /// [tel] 手机号
  /// [code] 验证码
  /// [captchaKey] 验证码密钥
  /// [cid] 国家代码
  /// [key] RSA公钥
  Future<LoginResultEntity> loginBySms({
    required String tel,
    required String code,
    required String captchaKey,
    required Object cid,
    required String key,
  });

  /// 获取加密公钥
  ///
  /// 返回包含hash和key的Map
  Future<Map<String, String>> getWebKey();

  /// 风控验证：获取信息
  ///
  /// [tmpCode] 临时代码
  Future<RiskVerifyInfoEntity> getRiskVerifyInfo({
    required String tmpCode,
  });

  /// 风控验证：发送短信验证码
  ///
  /// [tmpCode] 临时代码
  /// [geeChallenge] 极验挑战参数
  /// [geeSeccode] 极验seccode参数
  /// [geeValidate] 极验validate参数
  /// [recaptchaToken] reCAPTCHA令牌
  /// [refererUrl] 来源URL
  Future<SmsCodeEntity> sendRiskVerifySms({
    required String tmpCode,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
    required String refererUrl,
  });

  /// 风控验证：提交短信验证码
  ///
  /// [code] 验证码
  /// [tmpCode] 临时代码
  /// [requestId] 请求ID
  /// [source] 来源
  /// [captchaKey] 验证码密钥
  /// [refererUrl] 来源URL
  Future<String> submitRiskVerifySms({
    required String code,
    required String tmpCode,
    required String requestId,
    required String source,
    required String captchaKey,
    required String refererUrl,
  });

  /// OAuth2换取访问令牌
  ///
  /// [code] 授权码
  Future<LoginResultEntity> oauth2AccessToken({
    required String code,
  });

  /// 极验预验证
  ///
  /// 返回极验参数
  Future<Map<String, dynamic>> preCapture();

  /// 查询验证码
  Future<CaptchaDataModel> queryCaptcha();

  /// 简化的登录方法（用于演示干净架构迁移）
  ///
  /// [username] 用户名或邮箱
  /// [password] 密码
  ///
  /// 返回 [LoginEntity] 登录成功后的实体
  ///
  /// 抛出 [Failure] 当登录失败时
  Future<LoginEntity> performLogin({
    required String username,
    required String password,
  });

  /// 刷新令牌
  ///
  /// [refreshToken] 刷新令牌
  ///
  /// 返回新的 [LoginEntity]
  Future<LoginEntity> refreshToken(String refreshToken);

  /// 退出登录
  Future<void> logout();
}
