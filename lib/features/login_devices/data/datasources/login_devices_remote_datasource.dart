import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/login/data/datasources/login_api_datasource.dart';
import 'package:PiliPlus/models/login_devices/data.dart';
import 'package:PiliPlus/utils/accounts.dart';

/// Remote data source for login devices
class LoginDevicesRemoteDatasource {
  final _loginDataSource = LoginRemoteDataSource();

  /// Fetch login devices via API
  Future<LoadingState<LoginDevicesData>> getLoginDevices() async {
    try {
      final account = Accounts.main;
      final result = await _loginDataSource.loginDevicesWithData(
        csrf: account.csrf,
        accessKey: account.accessKey ?? '',
        buvid: LoginRemoteDataSource.buvid,
      );
      return Success(result);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
