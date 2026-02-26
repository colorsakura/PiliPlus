import 'dart:async';
import 'package:PiliPlus/features/dlna/domain/entities/dlna_device.dart';
import 'package:PiliPlus/features/dlna/domain/repositories/dlna_repository.dart';

/// Search DLNA devices use case
class SearchDlnaDevices {
  final DlnaRepository repository;

  const SearchDlnaDevices(this.repository);

  Stream<List<DlnaDeviceEntity>> call() {
    return repository.searchDevices();
  }
}
