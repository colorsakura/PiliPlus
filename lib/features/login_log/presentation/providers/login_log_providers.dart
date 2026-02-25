import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/login_log/data/datasources/login_log_remote_datasource.dart';
import 'package:PiliPlus/features/login_log/data/repositories/login_log_repository_impl.dart';
import 'package:PiliPlus/features/login_log/domain/repositories/login_log_repository.dart';
import 'package:PiliPlus/features/login_log/domain/usecases/get_login_log_usecase.dart';
import 'package:PiliPlus/features/login_log/presentation/providers/login_log_controller.dart';

// Remote Datasource Provider
final loginLogRemoteDatasourceProvider = Provider<LoginLogRemoteDatasource>((
  ref,
) {
  return const LoginLogRemoteDatasource();
});

// Repository Provider
final loginLogRepositoryProvider = Provider<LoginLogRepository>((ref) {
  final datasource = ref.watch(loginLogRemoteDatasourceProvider);
  return LoginLogRepositoryImpl(datasource);
});

// Use Case Provider
final getLoginLogUseCaseProvider = Provider<GetLoginLogUseCase>((ref) {
  final repository = ref.watch(loginLogRepositoryProvider);
  return GetLoginLogUseCase(repository);
});

// Controller Provider
final loginLogControllerProvider = Provider<LoginLogController>((ref) {
  return LoginLogController(
    getLoginLogUseCase: ref.watch(getLoginLogUseCaseProvider),
  );
});
