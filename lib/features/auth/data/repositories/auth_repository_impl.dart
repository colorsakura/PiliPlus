import 'package:PiliPlus/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:PiliPlus/features/auth/data/datasources/auth_remote_datasource_interface.dart';
import 'package:PiliPlus/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:PiliPlus/features/auth/domain/entities/auth_params.dart';
import 'package:PiliPlus/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of authentication repository
class AuthRepositoryImpl implements AuthRepository {
  final IAuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  /// Create from existing AuthRemoteDataSource
  static AuthRepositoryImpl fromDataSource(AuthRemoteDataSource dataSource) {
    return AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(dataSource),
    );
  }

  @override
  Future<Map<String, dynamic>> fetchTVCode(FetchTVCodeParams params) {
    return remoteDataSource.getHDCode();
  }

  @override
  Future<QRCodePollResult> pollQRCode(PollQRCodeParams params) {
    return remoteDataSource
        .codePoll(params.authCode)
        .then(
          (result) => QRCodePollResult(
            isSuccess: result['status'] == true,
            code: result['code'],
            data: result['data'],
            message: result['msg'],
          ),
        );
  }

  @override
  Future<Map<String, dynamic>> queryCaptcha() {
    return remoteDataSource.queryCaptcha();
  }
}
