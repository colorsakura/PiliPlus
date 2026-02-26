import 'dart:async';
import 'package:dlna_dart/dlna.dart';

/// DLNA remote data source interface
abstract class DlnaRemoteDataSource {
  /// Start DLNA device search
  Future<DeviceManager> startSearch();

  /// Stop device search
  void stopSearch();

  /// Get device by location
  DLNADevice? getDevice(String location);

  /// Add device to cache
  void addDevice(String location, DLNADevice device);

  /// Get all cached devices
  Map<String, DLNADevice> getAllDevices();
}

/// DLNA remote data source implementation
class DlnaRemoteDataSourceImpl implements DlnaRemoteDataSource {
  final DLNAManager _manager = DLNAManager();
  final Map<String, DLNADevice> _deviceCache = {};

  @override
  Future<DeviceManager> startSearch() async {
    _deviceCache.clear();
    return await _manager.start();
  }

  @override
  void stopSearch() {
    _manager.stop();
    _deviceCache.clear();
  }

  @override
  DLNADevice? getDevice(String location) {
    return _deviceCache[location];
  }

  @override
  void addDevice(String location, DLNADevice device) {
    _deviceCache[location] = device;
  }

  @override
  Map<String, DLNADevice> getAllDevices() {
    return Map.from(_deviceCache);
  }
}
