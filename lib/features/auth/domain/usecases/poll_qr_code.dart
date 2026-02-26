import 'package:PiliPlus/features/auth/domain/entities/auth_params.dart';
import 'package:PiliPlus/features/auth/domain/repositories/auth_repository.dart';

/// Use case for polling QR code login status
class PollQRCode {
  final AuthRepository repository;

  const PollQRCode(this.repository);

  Future<QRCodePollResult> call(PollQRCodeParams params) =>
      repository.pollQRCode(params);
}
