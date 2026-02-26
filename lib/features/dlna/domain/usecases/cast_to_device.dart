import 'package:PiliPlus/features/dlna/domain/repositories/dlna_repository.dart';

/// Cast content to DLNA device use case
class CastToDevice {
  final DlnaRepository repository;

  const CastToDevice(this.repository);

  Future<void> call({
    required String deviceId,
    required String url,
    String? title,
  }) {
    return repository.connectAndCast(
      deviceId: deviceId,
      url: url,
      title: title,
    );
  }
}
