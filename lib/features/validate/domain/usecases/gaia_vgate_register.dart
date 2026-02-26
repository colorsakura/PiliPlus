import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/validate/domain/repositories/validate_repository.dart';

/// Gaia Vgate register use case
class GaiaVgateRegister {
  final ValidateRepository repository;

  const GaiaVgateRegister(this.repository);

  Future<LoadingState<Map<String, dynamic>?>> call(String vVoucher) {
    return repository.gaiaVgateRegister(vVoucher);
  }
}
