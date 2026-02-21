/// 备份/恢复操作结果
class BackupResult {
  final bool success;
  final String? message;

  const BackupResult({
    required this.success,
    this.message,
  });

  factory BackupResult.success([String? message]) {
    return BackupResult(success: true, message: message);
  }

  factory BackupResult.failure(String message) {
    return BackupResult(success: false, message: message);
  }

  @override
  String toString() {
    return 'BackupResult{success: $success, message: $message}';
  }
}
