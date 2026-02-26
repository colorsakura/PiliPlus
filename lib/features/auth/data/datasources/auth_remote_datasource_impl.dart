import 'package:PiliPlus/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:PiliPlus/features/auth/data/datasources/auth_remote_datasource_interface.dart';

/// Implementation adapter that wraps existing AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final AuthRemoteDataSource _dataSource;

  const AuthRemoteDataSourceImpl(this._dataSource);

  @override
  String get deviceId => _dataSource.deviceId;

  @override
  String get buvid => _dataSource.buvid;

  @override
  Map<String, String> get headers => _dataSource.headers;

  @override
  Future<Map<String, dynamic>> getHDCode() => _dataSource.getHDCode();

  @override
  Future<Map<String, dynamic>> codePoll(String authCode) =>
      _dataSource.codePoll(authCode);

  @override
  Future<Map<String, dynamic>> queryCaptcha() => _dataSource.queryCaptcha();
}
