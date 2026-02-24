import 'package:PiliPlus/features/followed/domain/repositories/followed_repository.dart';

/// Use case for fetching user name
class GetUserNameUseCase {
  const GetUserNameUseCase(this._repository);

  final FollowedRepository _repository;

  /// Execute the use case
  Future<String?> call(int mid) => _repository.getUserName(mid);
}
