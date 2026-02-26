import 'dart:async';
import 'package:PiliPlus/features/dlna/domain/entities/dlna_device.dart';

/// DLNA repository interface
abstract class DlnaRepository {
  /// Search for DLNA devices
  /// Returns a stream of search results
  Stream<List<DlnaDeviceEntity>> searchDevices();

  /// Stop searching for devices
  Future<void> stopSearch();

  /// Connect to a DLNA device and cast content
  Future<void> connectAndCast({
    required String deviceId,
    required String url,
    String? title,
  });

  /// Disconnect from current device
  Future<void> disconnect();

  /// Pause playback on current device
  Future<void> pause();

  /// Resume playback on current device
  Future<void> play();
}
