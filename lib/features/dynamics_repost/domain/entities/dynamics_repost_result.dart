/// Entity representing the result of a dynamic repost operation
class DynamicsRepostResult {
  /// The newly created dynamic ID
  final String? dynId;

  /// Whether the operation was successful
  final bool isSuccess;

  /// Error message if operation failed
  final String? errorMessage;

  const DynamicsRepostResult({
    this.dynId,
    required this.isSuccess,
    this.errorMessage,
  });

  /// Create a success result
  factory DynamicsRepostResult.success([String? dynId]) {
    return DynamicsRepostResult(
      dynId: dynId,
      isSuccess: true,
    );
  }

  /// Create an error result
  factory DynamicsRepostResult.error(String errorMessage) {
    return DynamicsRepostResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
