import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/member/domain/repositories/member_repository.dart';

/// 关注成员用例
class FollowMemberUseCase {
  final MemberRepository _repository;

  FollowMemberUseCase(this._repository);

  /// 执行用例
  ///
  /// [mid] 成员ID
  /// [follow] 是否关注
  ///
  /// 抛出 [Failure] 当操作失败时
  Future<void> call({
    required int mid,
    required bool follow,
  }) async {
    try {
      if (mid <= 0) {
        throw const ValidationFailure('成员ID必须大于0');
      }

      await _repository.followMember(
        mid: mid,
        follow: follow,
      );
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on UnauthorizedException {
      throw UnauthorizedFailure();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
