/// Parameters for fetching TV login QR code
class FetchTVCodeParams {
  final String localId;
  final String platform;
  final String mobiApp;

  const FetchTVCodeParams({
    this.localId = '0',
    this.platform = 'android',
    this.mobiApp = 'android_hd',
  });
}

/// Parameters for polling QR code login status
class PollQRCodeParams {
  final String authCode;
  final String localId;

  const PollQRCodeParams({
    required this.authCode,
    this.localId = '0',
  });
}

/// Result of QR code poll
class QRCodePollResult {
  final bool isSuccess;
  final int code;
  final Map<String, dynamic>? data;
  final String? message;

  const QRCodePollResult({
    required this.isSuccess,
    required this.code,
    this.data,
    this.message,
  });

  /// Check if QR code is expired (code 86038)
  bool get isExpired => code == 86038;

  /// Check if QR code is scanned but not confirmed (code 86090)
  bool get isScanned => code == 86090;
}
