import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/login.dart';
import 'package:PiliPlus/models/login_devices/data.dart';

/// Remote data source for login devices
class LoginDevicesRemoteDatasource {
  const LoginDevicesRemoteDatasource();

  /// Fetch login devices via API
  Future<LoadingState<LoginDevicesData>> getLoginDevices() {
    return LoginHttp.loginDevices();
  }
}
