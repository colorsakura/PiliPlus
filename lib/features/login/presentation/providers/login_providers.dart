import 'package:PiliPlus/features/login/data/datasources/login_api_datasource.dart';
import 'package:PiliPlus/features/login/data/repositories/login_repository_impl.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';
import 'package:PiliPlus/features/login/domain/usecases/get_qr_code.dart';
import 'package:PiliPlus/features/login/domain/usecases/login_by_password.dart';
import 'package:PiliPlus/features/login/domain/usecases/login_by_sms.dart';
import 'package:PiliPlus/features/login/domain/usecases/send_sms_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
