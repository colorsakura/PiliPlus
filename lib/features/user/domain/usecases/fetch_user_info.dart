import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/features/user/domain/entities/user_params.dart';
import 'package:PiliPlus/features/user/domain/repositories/user_repository.dart';

/// Use case for fetching user information
class FetchUserInfo {
  final UserRepository repository;

  const FetchUserInfo(this.repository);

  Future<UserInfoData> call([FetchUserInfoParams? params]) =>
      repository.fetchUserInfo(params);
}
