import 'package:PiliPlus/features/auth/domain/repositories/auth_repository.dart';

/// Use case for querying captcha
class QueryCaptcha {
  final AuthRepository repository;

  const QueryCaptcha(this.repository);

  Future<Map<String, dynamic>> call() => repository.queryCaptcha();
}
