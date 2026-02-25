import 'package:PiliPlus/features/login_devices/data/datasources/login_devices_remote_datasource.dart';
import 'package:PiliPlus/features/login_devices/data/repositories/login_devices_repository_impl.dart';
import 'package:PiliPlus/features/login_devices/domain/repositories/login_devices_repository.dart';
import 'package:PiliPlus/features/login_devices/domain/usecases/get_login_devices_usecase.dart';
import 'package:PiliPlus/features/login_devices/presentation/providers/login_devices_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Remote datasource provider
final loginDevicesRemoteDatasourceProvider =
    Provider<LoginDevicesRemoteDatasource>((ref) {
  return LoginDevicesRemoteDatasource();
});

/// Repository provider
final loginDevicesRepositoryProvider = Provider<LoginDevicesRepository>((ref) {
  final datasource = ref.watch(loginDevicesRemoteDatasourceProvider);
  return LoginDevicesRepositoryImpl(datasource);
});

/// Get login devices use case provider
final getLoginDevicesUseCaseProvider = Provider<GetLoginDevicesUseCase>((ref) {
  final repository = ref.watch(loginDevicesRepositoryProvider);
  return GetLoginDevicesUseCase(repository);
});

/// Login devices controller provider
final loginDevicesControllerProvider =
    Provider<LoginDevicesController>((ref) {
  return LoginDevicesController(
    getLoginDevicesUseCase: ref.watch(getLoginDevicesUseCaseProvider),
  );
});
