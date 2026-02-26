import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/features/user/domain/entities/user_params.dart';
import 'package:PiliPlus/features/user/domain/repositories/user_repository.dart';

/// Use case for fetching user statistics
class FetchUserStat {
  final UserRepository repository;

  const FetchUserStat(this.repository);

  Future<UserStat> call(FetchUserStatParams params) =>
      repository.fetchUserStat(params);
}
