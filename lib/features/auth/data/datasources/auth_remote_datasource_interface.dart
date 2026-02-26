/// Data source interface for authentication operations
abstract class IAuthRemoteDataSource {
  /// Device ID
  String get deviceId;

  /// Buvid
  String get buvid;

  /// Request headers
  Map<String, String> get headers;

  /// Fetch TV login QR code
  Future<Map<String, dynamic>> getHDCode();

  /// Poll QR code for login status
  Future<Map<String, dynamic>> codePoll(String authCode);

  /// Query captcha
  Future<Map<String, dynamic>> queryCaptcha();
}
