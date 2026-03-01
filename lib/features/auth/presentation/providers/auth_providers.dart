import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:PiliPlus/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:PiliPlus/features/auth/data/datasources/auth_remote_datasource_interface.dart';
import 'package:PiliPlus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:PiliPlus/features/auth/domain/repositories/auth_repository.dart';
import 'package:PiliPlus/features/auth/domain/usecases/fetch_tv_code.dart';
import 'package:PiliPlus/features/auth/domain/usecases/poll_qr_code.dart';
import 'package:PiliPlus/features/auth/domain/usecases/query_captcha.dart';

/// Auth Remote Datasource Provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  final baseDataSource = AuthRemoteDataSource();
  return AuthRemoteDataSourceImpl(baseDataSource);
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(remoteDataSource: datasource);
});

/// Fetch TV Code UseCase Provider
final fetchTVCodeUseCaseProvider = Provider<FetchTVCode>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return FetchTVCode(repository);
});

/// Poll QR Code UseCase Provider
final pollQRCodeUseCaseProvider = Provider<PollQRCode>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return PollQRCode(repository);
});

/// Query Captcha UseCase Provider
final queryCaptchaUseCaseProvider = Provider<QueryCaptcha>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return QueryCaptcha(repository);
});
