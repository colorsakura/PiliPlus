/// 认证远程数据源
///
/// 负责所有登录、认证相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'dart:convert';

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/auth_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/utils/app_sign.dart';
import 'package:PiliPlus/utils/login_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';

/// 认证远程数据源
class AuthRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// 设备ID
  final String deviceId = LoginUtils.genDeviceId();

  /// Buvid
  String get buvid => LoginUtils.buvid;

  /// 请求头
  Map<String, String> get headers => {
    'buvid': buvid,
    'env': 'prod',
    'app-key': 'android_hd',
    'user-agent': 'Mozilla/5.0 BiliTV/1.0.0',
    'x-bili-trace-id': _generateTraceId(),
    'x-bili-aurora-eid': '',
    'x-bili-aurora-zone': '',
    'bili-http-engine': 'cronet',
    'content-type': 'application/x-www-form-urlencoded; charset=utf-8',
  };

  /// 获取电视登录二维码
  Future<Map<String, dynamic>> getHDCode() async {
    try {
      final params = {
        'local_id': '0',
        'platform': 'android',
        'mobi_app': 'android_hd',
      };
      AppSign.appSign(params);

      final response = await _httpClient.post(
        AuthApiConstants.getTVCode,
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

  /// 二维码轮询
  Future<Map<String, dynamic>> codePoll(String authCode) async {
    try {
      final params = {
        'auth_code': authCode,
        'local_id': '0',
      };
      AppSign.appSign(params);

      final response = await _httpClient.post(
        AuthApiConstants.qrcodePoll,
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

  /// 获取验证码
  Future<Map<String, dynamic>> queryCaptcha() async {
    try {
      final response = await _httpClient.get(AuthApiConstants.getCaptcha);

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取验证码失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取Web公钥（用于密码加密）
  Future<Map<String, dynamic>> getWebKey() async {
    try {
      final response = await _httpClient.get(AuthApiConstants.getWebKey);

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取公钥失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 发送短信验证码
  Future<void> sendSmsCode({
    required Object cid,
    required String tel,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
  }) async {
    try {
      final response = await _httpClient.post(
        AuthApiConstants.appSmsCode,
        data: {
          'cid': cid,
          'tel': tel,
          if (geeChallenge != null) 'gee_challenge': geeChallenge,
          if (geeSeccode != null) 'gee_seccode': geeSeccode,
          if (geeValidate != null) 'gee_validate': geeValidate,
        },
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '发送验证码失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 密码登录
  Future<Map<String, dynamic>> loginByPwd({
    required String username,
    required String password,
    String? captchaKey,
    String? captchaValue,
  }) async {
    try {
      // 获取公钥
      final keyData = await getWebKey();
      final String hash = keyData['hash'];
      final String pubKey = keyData['key'];

      // RSA加密密码
      final dynamic publicKey = RSAKeyParser().parse(pubKey);
      final encrypter = Encrypter(RSA(publicKey: publicKey));
      final encryptedPassword = encrypter.encrypt(password).base64;

      final response = await _httpClient.post(
        AuthApiConstants.loginByPwdApi,
        queryParameters:
            {
                  'username': username,
                  'password': encryptedPassword,
                  'captcha_key': hash,
                  if (captchaKey != null) 'captcha': captchaKey,
                  if (captchaValue != null) 'captcha_value': captchaValue,
                }
                as Map<String, dynamic>,
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '登录失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 短信验证码登录
  Future<Map<String, dynamic>> loginBySms({
    required Object cid,
    required String tel,
    required String code,
    int? statistics,
  }) async {
    try {
      final response = await _httpClient.post(
        AuthApiConstants.logInByAppSms,
        data: {
          'cid': cid,
          'tel': tel,
          'code': code,
          if (statistics != null) 'statistics': statistics,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '登录失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 获取安全中心信息
  Future<Map<String, dynamic>> safeCenterGetInfo({
    required String csrf,
  }) async {
    try {
      final response = await _httpClient.post(
        AuthApiConstants.safeCenterGetInfo,
        data: {
          'csrf': csrf,
          'csrf_token': csrf,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取安全信息失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 预验证码
  Future<Map<String, dynamic>> preCapture() async {
    try {
      final response = await _httpClient.get(AuthApiConstants.preCapture);

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取预验证码失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 安全中心发送短信
  Future<void> safeCenterSmsCode({
    required String csrf,
    required String buvid,
    required String mid,
  }) async {
    try {
      final response = await _httpClient.post(
        AuthApiConstants.safeCenterSmsCode,
        data: {
          'csrf': csrf,
          'csrf_token': csrf,
          'buvid': buvid,
          'mid': mid,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '发送短信失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 安全中心短信验证
  Future<Map<String, dynamic>> safeCenterSmsVerify({
    required String csrf,
    required String code,
    required String mid,
  }) async {
    try {
      final response = await _httpClient.post(
        AuthApiConstants.safeCenterSmsVerify,
        data: {
          'csrf': csrf,
          'csrf_token': csrf,
          'code': code,
          'mid': mid,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '验证失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// OAuth2获取AccessToken
  Future<Map<String, dynamic>> oauth2AccessToken({
    required String code,
    required String clientId,
    required String clientSecret,
  }) async {
    try {
      final response = await _httpClient.post(
        AuthApiConstants.oauth2AccessToken,
        data: {
          'code': code,
          'grant_type': 'authorization_code',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取AccessToken失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 退出登录
  Future<void> logout({
    required String csrf,
    required String refreshToken,
  }) async {
    try {
      final response = await _httpClient.post(
        AuthApiConstants.logout,
        data: {
          'biliCSRF': csrf,
          'refreshToken': refreshToken,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.data['code'] != 0) {
        throw ServerException(
          response.data['message'] ?? '退出登录失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 登录设备列表
  Future<Map<String, dynamic>> loginDevices() async {
    try {
      final response = await _httpClient.get(AuthApiConstants.loginDevices);

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取设备列表失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 辅助方法：生成trace ID
  String _generateTraceId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = (now % 1000000).toString().padLeft(6, '0');
    final hash = sha256
        .convert(utf8.encode('$now$random'))
        .toString()
        .substring(0, 16);
    return '$now$random:$hash:0.0';
  }
}
