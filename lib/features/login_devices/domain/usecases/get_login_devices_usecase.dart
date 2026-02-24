import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/login_devices/data.dart';
import 'package:PiliPlus/features/login_devices/domain/repositories/login_devices_repository.dart';

/// Use case for fetching login devices
class GetLoginDevicesUseCase {
  const GetLoginDevicesUseCase(this._repository);

  final LoginDevicesRepository _repository;

  Future<LoadingState<LoginDevicesData>> call() {
    return _repository.getLoginDevices();
  }
}
