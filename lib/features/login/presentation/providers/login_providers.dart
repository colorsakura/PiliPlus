import 'package:PiliPlus/features/login/data/datasources/login_api_datasource.dart';
import 'package:PiliPlus/features/login/data/datasources/login_remote_datasource.dart';
import 'package:PiliPlus/features/login/data/repositories/login_repository_impl.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';
import 'package:PiliPlus/features/login/domain/usecases/get_qr_code.dart';
import 'package:PiliPlus/features/login/domain/usecases/login_by_password.dart';
import 'package:PiliPlus/features/login/domain/usecases/login_by_sms.dart';
import 'package:PiliPlus/features/login/domain/usecases/send_sms_code.dart';
import 'package:PiliPlus/features/login/domain/usecases/perform_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

/// 登录远程数据源 Provider
final loginRemoteDataSourceProvider = Provider<LoginRemoteDataSource>((ref) {
  return LoginRemoteDataSource();
});

/// 登录仓库实现 Provider
final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  final remoteDataSource = ref.watch(loginRemoteDataSourceProvider);
  return LoginRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// 获取二维码用例 Provider
final getQRCodeUseCaseProvider = Provider<GetQRCodeUseCase>((ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return GetQRCodeUseCase(repository);
});

/// 密码登录用例 Provider
final loginByPasswordUseCaseProvider = Provider<LoginByPasswordUseCase>((ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return LoginByPasswordUseCase(repository);
});

/// 发送短信验证码用例 Provider
final sendSmsCodeUseCaseProvider = Provider<SendSmsCodeUseCase>((ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return SendSmsCodeUseCase(repository);
});

/// 短信验证码登录用例 Provider
final loginBySmsUseCaseProvider = Provider<LoginBySmsUseCase>((ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return LoginBySmsUseCase(repository);
});

// ========== 简化登录功能的 Providers（用于演示干净架构） ==========

/// Dio HTTP Client Provider（用于简化登录）
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://api.bilibili.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

/// 简化的登录远程数据源 Provider
final simplifiedLoginRemoteDatasourceProvider =
    Provider<LoginRemoteDatasource>((ref) {
  return LoginRemoteDatasource(ref.watch(dioProvider));
});

/// 简化的登录用例 Provider
final performLoginUseCaseProvider = Provider<PerformLoginUseCase>((ref) {
  return PerformLoginUseCase(ref.watch(loginRepositoryProvider));
});
