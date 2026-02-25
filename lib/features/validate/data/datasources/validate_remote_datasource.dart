/// 验证远程数据源
///
/// 负责所有验证相关的网络请求
library;

// 忽略类型推断警告
// ignore_for_file: prefer_collection_literals, map_value_type_not_assignable

import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/validate_api_constants.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:dio/dio.dart';

/// 验证远程数据源
class ValidateRemoteDataSource {
  final Dio _httpClient = HttpClientManager.instance;

  /// Gaia 验证码注册
  ///
  /// [vVoucher] 验证凭证
  Future<Map<String, dynamic>?> gaiaVgateRegister(String vVoucher) async {
    try {
      final response = await _httpClient.post(
        ValidateApiConstants.gaiaVgateRegister,
        queryParameters: {
          if (Accounts.main.isLogin) 'csrf': Accounts.main.csrf,
        },
        data: {
          'v_voucher': vVoucher,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? 'Gaia 验证码注册失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Gaia 验证码验证
  ///
  /// [challenge] 挑战值
  /// [seccode] 安全码
  /// [token] 令牌
  /// [validate] 验证值
  Future<Map<String, dynamic>?> gaiaVgateValidate({
    required dynamic challenge,
    required dynamic seccode,
    required dynamic token,
    required dynamic validate,
  }) async {
    try {
      final response = await _httpClient.post(
        ValidateApiConstants.gaiaVgateValidate,
        queryParameters: {
          if (Accounts.main.isLogin) 'csrf': Accounts.main.csrf,
        },
        data: {
          'challenge': challenge,
          'seccode': seccode,
          'token': token,
          'validate': validate,
        },
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? 'Gaia 验证码验证失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
