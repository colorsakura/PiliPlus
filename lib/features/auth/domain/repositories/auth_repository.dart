import 'package:PiliPlus/features/auth/domain/entities/auth_params.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Fetch TV login QR code
  Future<Map<String, dynamic>> fetchTVCode(FetchTVCodeParams params);

  /// Poll QR code for login status
  Future<QRCodePollResult> pollQRCode(PollQRCodeParams params);

  /// Query captcha if needed
  Future<Map<String, dynamic>> queryCaptcha();
}
