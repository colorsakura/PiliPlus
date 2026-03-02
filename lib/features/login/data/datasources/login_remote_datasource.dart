import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/login/data/models/login_model.dart';
import 'package:dio/dio.dart';

/// 登录远程数据源
///
/// 负责与登录相关的 API 交互（简化版用于演示）
class LoginRemoteDatasource {
  final Dio _httpClient;

  LoginRemoteDatasource(this._httpClient);

  /// 执行登录 API 调用
  ///
  /// [username] 用户名或邮箱
  /// [password] 密码
  ///
  /// 返回 [LoginModel]
  ///
  /// 抛出 [ServerException] 当服务器返回错误时
  /// 抛出 [NetworkException] 当网络错误时
  /// 抛出 [UnauthorizedException] 当凭证无效时
  Future<LoginModel> performLogin({
    required String username,
    required String password,
  }) async {
    try {
      // 注意：这是一个简化的实现用于演示干净架构模式
      // 在实际生产中，应该使用现有的 LoginApiDataSource.loginByPwd 方法
      // 并正确处理 RSA 加密、极验验证等

      final response = await _httpClient.post(
        '/x/passport-login/oauth2/access_token',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw UnauthorizedException();
        }
        throw ServerException(
          '登录失败: ${response.statusMessage}',
          code: response.statusCode,
        );
      }

      final data = response.data;
      if (data['code'] != 0) {
        if (data['code'] == -101) {
          throw UnauthorizedException();
        }
        throw ServerException(
          data['message'] ?? '登录失败',
          code: data['code'],
        );
      }

      return LoginModel.fromJson(data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.data['code'] == -101) {
        throw UnauthorizedException();
      }
      throw ServerException(
        e.message ?? '网络错误',
        code: e.response?.statusCode,
      );
    } on NetworkException {
      rethrow;
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
