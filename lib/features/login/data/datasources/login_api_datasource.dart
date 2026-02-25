/// Login API Remote DataSource
///
/// 负责所有登录相关的网络请求
library;

import 'dart:convert';

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/constants/login_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/models/login/model.dart';
import 'package:PiliPlus/models/login_devices/data.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/app_sign.dart';
import 'package:PiliPlus/utils/login_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';

/// Login API 远程数据源
class LoginRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  static final String deviceId = LoginUtils.genDeviceId();
  static String get buvid => LoginUtils.buvid;

  static final Map<String, String> headers = {
    'buvid': buvid,
    'env': 'prod',
    'app-key': 'android_hd',
    'user-agent': Constants.userAgent,
    'x-bili-trace-id': Constants.traceId,
    'x-bili-aurora-eid': '',
    'x-bili-aurora-zone': '',
    'bili-http-engine': 'cronet',
    'content-type': 'application/x-www-form-urlencoded; charset=utf-8',
  };

  /// 获取电视扫码登录二维码
  ///
  /// 返回包含 authCode 和 url 的记录
  Future<Map<String, dynamic>> getHDCode() async {
    try {
      final params = {
        'local_id': '0',
        'platform': 'android',
        'mobi_app': 'android_hd',
      };
      AppSign.appSign(params);

      final response = await _httpClient.post(
        LoginApiConstants.getTVCode,
        queryParameters: params,
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取二维码失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 轮询二维码扫码状态
  ///
  /// [authCode] 二维码授权码
  Future<Map<String, dynamic>> codePoll(String authCode) async {
    try {
      final params = {
        'auth_code': authCode,
        'local_id': '0',
      };
      AppSign.appSign(params);

      final response = await _httpClient.post(
        LoginApiConstants.qrcodePoll,
        queryParameters: params,
      );

      return {
        'status': response.data['code'] == 0,
        'code': response.data['code'],
        'data': response.data['data'],
        'msg': response.data['message'],
      };
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 查询验证码
  Future<Map<String, dynamic>> queryCaptcha() async {
    try {
      final response = await _httpClient.get(LoginApiConstants.getCaptcha);

      if (response.data['code'] == 0) {
        return {
          'status': true,
          'data': CaptchaDataModel.fromJson(response.data['data']),
        };
      } else {
        return {'status': false, 'data': response.data['message']};
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取加密公钥
  Future<Map<String, dynamic>> getWebKey() async {
    try {
      final response = await _httpClient.get(LoginApiConstants.getWebKey);

      if (response.data['code'] == 0) {
        return {'status': true, 'data': response.data['data']};
      } else {
        return {'status': false, 'data': {}, 'msg': response.data['message']};
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 发送短信验证码
  ///
  /// [cid] 国家代码
  /// [tel] 手机号
  /// [geeChallenge] 极验挑战参数
  /// [geeSeccode] 极验seccode参数
  /// [geeValidate] 极验validate参数
  /// [recaptchaToken] reCAPTCHA令牌
  Future<Map<String, dynamic>> sendSmsCode({
    required Object cid,
    required String tel,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final data = {
        'build': '2001100',
        'buvid': buvid,
        'c_locale': 'zh_CN',
        'channel': 'master',
        'cid': cid,
        'disable_rcmd': '0',
        'gee_challenge': ?geeChallenge,
        'gee_seccode': ?geeSeccode,
        'gee_validate': ?geeValidate,
        'local_id': buvid,
        'login_session_id': md5
            .convert(ascii.encode(buvid + timestamp.toString()))
            .toString(),
        'mobi_app': 'android_hd',
        'platform': 'android',
        'recaptcha_token': ?recaptchaToken,
        's_locale': 'zh_CN',
        'statistics': Constants.statistics,
        'tel': tel,
        'ts': (timestamp ~/ 1000).toString(),
      };
      AppSign.appSign(data);

      final response = await _httpClient.post(
        LoginApiConstants.appSmsCode,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: headers,
        ),
      );

      if (response.data['code'] == 0 &&
          response.data['data']['recaptcha_url'] == "") {
        return {'status': true, 'data': response.data['data']};
      } else {
        return {
          'status': false,
          'code': response.data['code'],
          'msg': response.data['message'],
          'data': response.data['data'],
        };
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

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
  Future<Map<String, dynamic>> loginByPwd({
    required String username,
    required String password,
    required String key,
    required String salt,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  }) async {
    try {
      final dynamic publicKey = RSAKeyParser().parse(key);
      final passwordEncrypted = Encrypter(
        RSA(publicKey: publicKey),
      ).encrypt(salt + password).base64;

      final data = {
        'bili_local_id': deviceId,
        'build': '2001100',
        'buvid': buvid,
        'c_locale': 'zh_CN',
        'channel': 'master',
        'device': 'phone',
        'device_id': deviceId,
        'device_name': 'vivo',
        'device_platform': 'Android14vivo',
        'disable_rcmd': '0',
        'dt': Uri.encodeComponent(
          Encrypter(
            RSA(publicKey: publicKey),
          ).encrypt(Utils.generateRandomString(16)).base64,
        ),
        'from_pv': 'main.homepage.avatar-nologin.all.click',
        'from_url': Uri.encodeComponent('bilibili://pegasus/promo'),
        'gee_challenge': ?geeChallenge,
        'gee_seccode': ?geeSeccode,
        'gee_validate': ?geeValidate,
        'local_id': buvid,
        'mobi_app': 'android_hd',
        'password': passwordEncrypted,
        'permission': 'ALL',
        'platform': 'android',
        'recaptcha_token': ?recaptchaToken,
        's_locale': 'zh_CN',
        'statistics': Constants.statistics,
        'username': username,
      };
      AppSign.appSign(data);

      final response = await _httpClient.post(
        LoginApiConstants.loginByPwdApi,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: headers,
        ),
      );

      if (response.data['code'] == 0) {
        return {
          'status': true,
          'data': response.data['data'],
          'msg': response.data['message'],
        };
      } else {
        return {
          'status': false,
          'code': response.data['code'],
          'msg': response.data['message'],
          'data': response.data['data'],
        };
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 短信验证码登录
  ///
  /// [captchaKey] 验证码密钥
  /// [tel] 手机号
  /// [code] 短信验证码
  /// [cid] 国家代码
  /// [key] RSA公钥
  Future<Map<String, dynamic>> loginBySms({
    required String captchaKey,
    required String tel,
    required String code,
    required Object cid,
    required String key,
  }) async {
    try {
      final dynamic publicKey = RSAKeyParser().parse(key);
      final data = {
        'bili_local_id': deviceId,
        'build': '2001100',
        'buvid': buvid,
        'c_locale': 'zh_CN',
        'captcha_key': captchaKey,
        'channel': 'master',
        'cid': cid,
        'code': code,
        'device': 'phone',
        'device_id': deviceId,
        'device_name': 'vivo',
        'device_platform': 'Android14vivo',
        'disable_rcmd': '0',
        'dt': Uri.encodeComponent(
          Encrypter(
            RSA(publicKey: publicKey),
          ).encrypt(Utils.generateRandomString(16)).base64,
        ),
        'from_pv': 'main.my-information.my-login.0.click',
        'from_url': Uri.encodeComponent('bilibili://user_center/mine'),
        'local_id': buvid,
        'mobi_app': 'android_hd',
        'platform': 'android',
        's_locale': 'zh_CN',
        'statistics': Constants.statistics,
        'tel': tel,
      };
      AppSign.appSign(data);

      final response = await _httpClient.post(
        LoginApiConstants.logInByAppSms,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: headers,
        ),
      );

      if (response.data['code'] == 0) {
        return {'status': true, 'data': response.data['data']};
      } else {
        return {
          'status': false,
          'code': response.data['code'],
          'msg': response.data['message'],
          'data': response.data['data'],
        };
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 风控验证：获取信息
  Future<Map<String, dynamic>> safeCenterGetInfo({
    required String tmpCode,
  }) async {
    try {
      final response = await _httpClient.get(
        LoginApiConstants.safeCenterGetInfo,
        queryParameters: {'tmp_code': tmpCode},
      );

      if (response.data['code'] == 0) {
        return {'status': true, 'data': response.data['data']};
      } else {
        return {
          'status': false,
          'code': response.data['code'],
          'msg': response.data['message'],
          'data': response.data['data'],
        };
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 极验预验证
  Future<Map<String, dynamic>> preCapture() async {
    try {
      final response = await _httpClient.post(LoginApiConstants.preCapture);

      if (response.data['code'] == 0) {
        return {'status': true, 'data': response.data['data']};
      } else {
        return {
          'status': false,
          'code': response.data['code'],
          'msg': response.data['message'],
          'data': response.data['data'],
        };
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 风控验证：发送短信验证码
  Future<Map<String, dynamic>> safeCenterSmsCode({
    String? smsType,
    required String tmpCode,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
    required String refererUrl,
  }) async {
    try {
      final data = {
        'disable_rcmd': '0',
        'sms_type': smsType ?? 'loginTelCheck',
        'tmp_code': tmpCode,
        'gee_challenge': ?geeChallenge,
        'gee_seccode': ?geeSeccode,
        'gee_validate': ?geeValidate,
        'recaptcha_token': ?recaptchaToken,
      };
      AppSign.appSign(data);

      final response = await _httpClient.post(
        LoginApiConstants.safeCenterSmsCode,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {"Referer": refererUrl},
        ),
      );

      if (response.data['code'] == 0) {
        return {'status': true, 'data': response.data['data']};
      } else {
        return {
          'status': false,
          'code': response.data['code'],
          'msg': response.data['message'],
          'data': response.data['data'],
        };
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 风控验证：提交短信验证码
  Future<Map<String, dynamic>> safeCenterSmsVerify({
    String? type,
    required String code,
    required String tmpCode,
    required String requestId,
    required String source,
    required String captchaKey,
    required String refererUrl,
  }) async {
    try {
      final data = {
        'type': type ?? 'loginTelCheck',
        'code': code,
        'tmp_code': tmpCode,
        'request_id': requestId,
        'source': source,
        'captcha_key': captchaKey,
      };
      AppSign.appSign(data);

      final response = await _httpClient.post(
        LoginApiConstants.safeCenterSmsVerify,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {"Referer": refererUrl},
        ),
      );

      if (response.data['code'] == 0) {
        return {'status': true, 'data': response.data['data']};
      } else {
        return {
          'status': false,
          'code': response.data['code'],
          'msg': response.data['message'],
          'data': response.data['data'],
        };
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// OAuth2 换取访问令牌
  Future<Map<String, dynamic>> oauth2AccessToken({
    required String code,
  }) async {
    try {
      final data = {
        'build': '2001100',
        'buvid': buvid,
        'code': code,
        'disable_rcmd': '0',
        'grant_type': 'authorization_code',
        'local_id': buvid,
        'mobi_app': 'android_hd',
        'platform': 'android',
      };
      AppSign.appSign(data);

      final response = await _httpClient.post(
        LoginApiConstants.oauth2AccessToken,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: headers,
        ),
      );

      if (response.data['code'] == 0) {
        return {'status': true, 'data': response.data['data']};
      } else {
        return {
          'status': false,
          'code': response.data['code'],
          'msg': response.data['message'],
          'data': response.data['data'],
        };
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 退出登录
  Future<Map<String, dynamic>> logout(Account account) async {
    try {
      final response = await _httpClient.post(
        LoginApiConstants.logout,
        data: {'biliCSRF': account.csrf},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          extra: {'account': account},
        ),
      );

      return {
        'status': response.data['code'] == 0,
        'msg': response.data['message'],
      };
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取登录设备列表
  Future<LoginDevicesData> loginDevices() async {
    // 这个方法需要 Accounts.main 和 Constants.statistics
    // 在实际使用时需要从外部传入这些参数，或者直接在调用处处理
    throw UnimplementedError('请使用 loginDevicesWithData 方法');
  }

  /// 获取登录设备列表（带参数）
  ///
  /// [csrf] CSRF令牌
  /// [accessKey] 访问密钥
  /// [buvid] 设备标识
  Future<LoginDevicesData> loginDevicesWithData({
    required String csrf,
    required String accessKey,
    required String buvid,
  }) async {
    try {
      final params = {
        'local_id': buvid,
        'buvid': buvid,
        'device_name': 'android',
        'device_platform': 'android',
        'csrf': csrf,
        'mobi_app': 'android_hd',
        'platform': 'android',
        'access_key': accessKey,
        'statistics': Constants.statistics,
      };
      AppSign.appSign(params);

      final response = await _httpClient.get(
        LoginApiConstants.loginDevices,
        queryParameters: params,
      );

      if (response.data['code'] == 0) {
        return LoginDevicesData.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? '获取登录设备列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
