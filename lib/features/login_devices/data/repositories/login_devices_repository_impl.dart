import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/login_devices/data.dart';
import 'package:PiliPlus/features/login_devices/domain/repositories/login_devices_repository.dart';
import 'package:PiliPlus/features/login_devices/data/datasources/login_devices_remote_datasource.dart';

/// Repository implementation for login devices
class LoginDevicesRepositoryImpl implements LoginDevicesRepository {
  const LoginDevicesRepositoryImpl(this._remoteDatasource);

  final LoginDevicesRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<LoginDevicesData>> getLoginDevices() {
    return _remoteDatasource.getLoginDevices();
  }
}
