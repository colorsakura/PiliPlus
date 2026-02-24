import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/login_devices/data.dart';

/// Repository interface for login devices
abstract class LoginDevicesRepository {
  /// Fetch login devices list
  Future<LoadingState<LoginDevicesData>> getLoginDevices();
}
