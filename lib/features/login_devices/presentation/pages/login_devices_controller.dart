import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/login_devices/data/datasources/login_devices_remote_datasource.dart';
import 'package:PiliPlus/models/login_devices/data.dart';
import 'package:PiliPlus/models/login_devices/device.dart';
import 'package:PiliPlus/core/controllers/common_list_controller.dart';

class LoginDevicesController
    extends CommonListController<LoginDevicesData, LoginDevice> {
  final _dataSource = LoginDevicesRemoteDatasource();
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<LoginDevice>? getDataList(LoginDevicesData response) {
    return response.devices;
  }

  @override
  Future<LoadingState<LoginDevicesData>> customGetData() =>
      _dataSource.getLoginDevices();
}
