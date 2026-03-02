import 'package:PiliPlus/features/login/data/datasources/login_api_datasource.dart';
import 'package:PiliPlus/features/login/data/datasources/login_remote_datasource.dart';
import 'package:PiliPlus/features/login/data/mappers/login_mapper.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/login_result_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/qr_code_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/risk_verify_info_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/sms_code_entity.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';
import 'package:PiliPlus/models/login/model.dart';

/// 登录仓库实现
class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource _remoteDataSource;
  final LoginRemoteDatasource? _simplifiedDatasource;

  LoginRepositoryImpl({
    required LoginRemoteDataSource remoteDataSource,
    LoginRemoteDatasource? simplifiedDatasource,
  }) : _remoteDataSource = remoteDataSource,
       _simplifiedDatasource = simplifiedDatasource;

  @override
  Future<QrCodeEntity> getQRCode() async {
    final data = await _remoteDataSource.getHDCode();
    return QrCodeEntity.fromMap(data);
  }

  @override
  Future<Map<String, dynamic>> pollQRCode(String authCode) async {
    return await _remoteDataSource.codePoll(authCode);
  }

  @override
  Future<LoginResultEntity> loginByPassword({
    required String username,
    required String password,
    required String key,
    required String salt,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  }) async {
    final result = await _remoteDataSource.loginByPwd(
      username: username,
      password: password,
      key: key,
      salt: salt,
      geeChallenge: geeChallenge,
      geeSeccode: geeSeccode,
      geeValidate: geeValidate,
      recaptchaToken: recaptchaToken,
    );

    if (result['status'] == true) {
      final data = result['data'] as Map<String, dynamic>?;

      // 检查是否需要风控验证
      if (data != null && data['status'] == 2) {
        return LoginResultEntity.needRiskVerify(
          verifyUrl: data['url'] as String,
        );
      }

      // 检查token和cookie是否存在
      if (data == null ||
          data['token_info'] == null ||
          data['cookie_info'] == null) {
        return LoginResultEntity.failure(
          errorMessage: result['msg'] as String? ?? '登录异常',
        );
      }

      // 解析token和cookie
      final tokenInfo = TokenInfo.fromMap(
        data['token_info'] as Map<String, dynamic>,
      );

      final cookiesList = data['cookie_info']['cookies'] as List;
      final cookies = cookiesList
          .map((cookie) => CookieInfo.fromMap(cookie as Map<String, dynamic>))
          .toList();

      return LoginResultEntity.success(
        tokenInfo: tokenInfo,
        cookies: cookies,
      );
    } else {
      // 检查是否需要验证码
      final code = result['code'] as int?;
      if (code == -105) {
        final data = result['data'] as Map<String, dynamic>?;
        if (data != null && data['url'] != null) {
          return LoginResultEntity.needRiskVerify(
            verifyUrl: data['url'] as String,
          );
        }
      }

      return LoginResultEntity.failure(
        errorCode: result['code'] as int?,
        errorMessage: result['msg'] as String? ?? '登录失败',
      );
    }
  }

  @override
  Future<SmsCodeEntity> sendSmsCode({
    required Object cid,
    required String tel,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  }) async {
    final result = await _remoteDataSource.sendSmsCode(
      cid: cid,
      tel: tel,
      geeChallenge: geeChallenge,
      geeSeccode: geeSeccode,
      geeValidate: geeValidate,
      recaptchaToken: recaptchaToken,
    );

    if (result['status'] == true) {
      return SmsCodeEntity.fromMap(result['data'] as Map<String, dynamic>);
    } else {
      throw Exception(
        '发送短信验证码失败: ${result['code']} - ${result['msg']}',
      );
    }
  }

  @override
  Future<LoginResultEntity> loginBySms({
    required String tel,
    required String code,
    required String captchaKey,
    required Object cid,
    required String key,
  }) async {
    final result = await _remoteDataSource.loginBySms(
      tel: tel,
      code: code,
      captchaKey: captchaKey,
      cid: cid,
      key: key,
    );

    if (result['status'] == true) {
      final data = result['data'] as Map<String, dynamic>;

      final tokenInfo = TokenInfo.fromMap(
        data['token_info'] as Map<String, dynamic>,
      );

      final cookiesList = data['cookie_info']['cookies'] as List;
      final cookies = cookiesList
          .map((cookie) => CookieInfo.fromMap(cookie as Map<String, dynamic>))
          .toList();

      return LoginResultEntity.success(
        tokenInfo: tokenInfo,
        cookies: cookies,
      );
    } else {
      return LoginResultEntity.failure(
        errorCode: result['code'] as int?,
        errorMessage: result['msg'] as String? ?? '登录失败',
      );
    }
  }

  @override
  Future<Map<String, String>> getWebKey() async {
    final result = await _remoteDataSource.getWebKey();
    if (result['status'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      return {
        'key': data['key'] as String,
        'hash': data['hash'] as String,
      };
    } else {
      throw Exception('获取公钥失败: ${result['msg']}');
    }
  }

  @override
  Future<RiskVerifyInfoEntity> getRiskVerifyInfo({
    required String tmpCode,
  }) async {
    final result = await _remoteDataSource.safeCenterGetInfo(tmpCode: tmpCode);
    if (result['status'] == true) {
      return RiskVerifyInfoEntity.fromMap(
        result['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception('获取风控信息失败: ${result['msg']}');
    }
  }

  @override
  Future<SmsCodeEntity> sendRiskVerifySms({
    required String tmpCode,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
    required String refererUrl,
  }) async {
    final result = await _remoteDataSource.safeCenterSmsCode(
      tmpCode: tmpCode,
      geeChallenge: geeChallenge,
      geeSeccode: geeSeccode,
      geeValidate: geeValidate,
      recaptchaToken: recaptchaToken,
      refererUrl: refererUrl,
    );

    if (result['status'] == true) {
      return SmsCodeEntity.fromMap(result['data'] as Map<String, dynamic>);
    } else {
      throw Exception(
        '发送风控短信验证码失败: ${result['code']} - ${result['msg']}',
      );
    }
  }

  @override
  Future<String> submitRiskVerifySms({
    required String code,
    required String tmpCode,
    required String requestId,
    required String source,
    required String captchaKey,
    required String refererUrl,
  }) async {
    final result = await _remoteDataSource.safeCenterSmsVerify(
      code: code,
      tmpCode: tmpCode,
      requestId: requestId,
      source: source,
      captchaKey: captchaKey,
      refererUrl: refererUrl,
    );

    if (result['status'] == true) {
      return result['data']['code'] as String;
    } else {
      throw Exception(
        '提交风控短信验证码失败: ${result['code']} - ${result['msg']}',
      );
    }
  }

  @override
  Future<LoginResultEntity> oauth2AccessToken({
    required String code,
  }) async {
    final result = await _remoteDataSource.oauth2AccessToken(code: code);

    if (result['status'] == true) {
      final data = result['data'] as Map<String, dynamic>;

      final tokenInfo = TokenInfo.fromMap(
        data['token_info'] as Map<String, dynamic>,
      );

      final cookiesList = data['cookie_info']['cookies'] as List;
      final cookies = cookiesList
          .map((cookie) => CookieInfo.fromMap(cookie as Map<String, dynamic>))
          .toList();

      return LoginResultEntity.success(
        tokenInfo: tokenInfo,
        cookies: cookies,
      );
    } else {
      return LoginResultEntity.failure(
        errorCode: result['code'] as int?,
        errorMessage: result['msg'] as String? ?? 'OAuth2登录失败',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> preCapture() async {
    return await _remoteDataSource.preCapture();
  }

  @override
  Future<CaptchaDataModel> queryCaptcha() async {
    final result = await _remoteDataSource.queryCaptcha();
    if (result['status'] == true) {
      return result['data'] as CaptchaDataModel;
    } else {
      throw Exception('查询验证码失败: ${result['data']}');
    }
  }

  @override
  Future<LoginEntity> performLogin({
    required String username,
    required String password,
  }) async {
    final datasource = _simplifiedDatasource;
    if (datasource == null) {
      throw UnimplementedError(
        'performLogin requires simplifiedDatasource to be provided',
      );
    }
    final model = await datasource.performLogin(
      username: username,
      password: password,
    );
    return LoginMapper.toEntity(model);
  }

  @override
  Future<LoginEntity> refreshToken(String refreshToken) async {
    // TODO: 实现令牌刷新逻辑
    throw UnimplementedError('refreshToken not implemented');
  }

  @override
  Future<void> logout() async {
    // TODO: 实现退出登录逻辑
    throw UnimplementedError('logout not implemented');
  }
}
