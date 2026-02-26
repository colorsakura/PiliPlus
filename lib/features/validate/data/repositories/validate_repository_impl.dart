import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/validate/data/datasources/validate_remote_datasource.dart';
import 'package:PiliPlus/features/validate/domain/repositories/validate_repository.dart';

/// Validate repository implementation
class ValidateRepositoryImpl implements ValidateRepository {
  final ValidateRemoteDataSource remoteDataSource;

  const ValidateRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<Map<String, dynamic>?>> gaiaVgateRegister(
      String vVoucher) async {
    try {
      final data = await remoteDataSource.gaiaVgateRegister(vVoucher);
      return Success(data);
    } on ServerException catch (e) {
      return Error(e.message ?? 'Gaia 验证码注册失败');
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<Map<String, dynamic>?>> gaiaVgateValidate({
    required dynamic challenge,
    required dynamic seccode,
    required dynamic token,
    required dynamic validate,
  }) async {
    try {
      final data = await remoteDataSource.gaiaVgateValidate(
        challenge: challenge,
        seccode: seccode,
        token: token,
        validate: validate,
      );
      return Success(data);
    } on ServerException catch (e) {
      return Error(e.message ?? 'Gaia 验证码验证失败');
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }
}
