import 'package:PiliPlus/features/follow_same/domain/repositories/follow_same_repository.dart';

/// Use case for fetching user name
class GetSameUserNameUseCase {
  const GetSameUserNameUseCase(this._repository);

  final FollowSameRepository _repository;

  /// Execute the use case
  Future<String?> call(int mid) => _repository.getUserName(mid);
}
