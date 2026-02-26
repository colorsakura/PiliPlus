import 'dart:async';
import 'package:dlna_dart/dlna.dart';
import 'package:PiliPlus/features/dlna/data/datasources/dlna_remote_datasource.dart';
import 'package:PiliPlus/features/dlna/domain/entities/dlna_device.dart';
import 'package:PiliPlus/features/dlna/domain/repositories/dlna_repository.dart';

/// DLNA repository implementation
class DlnaRepositoryImpl implements DlnaRepository {
  final DlnaRemoteDataSource remoteDataSource;
  DLNADevice? _currentDevice;
  String? _currentDeviceId;

  DlnaRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Stream<List<DlnaDeviceEntity>> searchDevices() async* {
    final manager = await remoteDataSource.startSearch();

    yield* manager.devices.stream.map((deviceMap) {
      final entities = deviceMap.entries.map((entry) {
        final location = entry.key;
        final device = entry.value;
        remoteDataSource.addDevice(location, device);
        return DlnaDeviceEntity(
          id: location,
          name: device.info.friendlyName,
          location: location,
          isConnected: location == _currentDeviceId,
        );
      }).toList();

      return entities;
    });
  }

  @override
  Future<void> stopSearch() {
    return Future.sync(() => remoteDataSource.stopSearch());
  }

  @override
  Future<void> connectAndCast({
    required String deviceId,
    required String url,
    String? title,
  }) async {
    // Pause current device if any
    if (_currentDevice != null && _currentDeviceId != deviceId) {
      await _currentDevice?.pause();
    }

    // Get new device
    final device = remoteDataSource.getDevice(deviceId);
    if (device == null) {
      throw Exception('Device not found: $deviceId');
    }

    // Set URL and play
    await device.setUrl(url, title: title ?? '');
    await device.play();

    _currentDevice = device;
    _currentDeviceId = deviceId;
  }

  @override
  Future<void> disconnect() async {
    await _currentDevice?.pause();
    _currentDevice = null;
    _currentDeviceId = null;
  }

  @override
  Future<void> pause() {
    return _currentDevice?.pause() ?? Future.value();
  }

  @override
  Future<void> play() {
    return _currentDevice?.play() ?? Future.value();
  }
}
