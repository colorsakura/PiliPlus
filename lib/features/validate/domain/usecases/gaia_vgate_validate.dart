import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/validate/domain/repositories/validate_repository.dart';

/// Gaia Vgate validate use case
class GaiaVgateValidate {
  final ValidateRepository repository;

  const GaiaVgateValidate(this.repository);

  Future<LoadingState<Map<String, dynamic>?>> call({
    required dynamic challenge,
    required dynamic seccode,
    required dynamic token,
    required dynamic validate,
  }) {
    return repository.gaiaVgateValidate(
      challenge: challenge,
      seccode: seccode,
      token: token,
      validate: validate,
    );
  }
}
