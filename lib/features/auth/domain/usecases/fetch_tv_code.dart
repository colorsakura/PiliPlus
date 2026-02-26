import 'package:PiliPlus/features/auth/domain/entities/auth_params.dart';
import 'package:PiliPlus/features/auth/domain/repositories/auth_repository.dart';

/// Use case for fetching TV login QR code
class FetchTVCode {
  final AuthRepository repository;

  const FetchTVCode(this.repository);

  Future<Map<String, dynamic>> call([FetchTVCodeParams? params]) =>
      repository.fetchTVCode(params ?? const FetchTVCodeParams());
}
