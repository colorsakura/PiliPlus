import 'package:PiliPlus/http/loading_state.dart';

/// Validate repository interface
abstract class ValidateRepository {
  /// Gaia verification code registration
  Future<LoadingState<Map<String, dynamic>?>> gaiaVgateRegister(String vVoucher);

  /// Gaia verification code validation
  Future<LoadingState<Map<String, dynamic>?>> gaiaVgateValidate({
    required dynamic challenge,
    required dynamic seccode,
    required dynamic token,
    required dynamic validate,
  });
}
