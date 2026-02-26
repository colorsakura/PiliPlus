import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/member/domain/entities/member_space_entity.dart';
import 'package:PiliPlus/features/member/domain/repositories/member_repository.dart';

/// 获取成员空间用例
class GetMemberSpaceUseCase {
  final MemberRepository _repository;

  GetMemberSpaceUseCase(this._repository);

  /// 执行用例
  ///
  /// [mid] 成员ID
  /// [fromViewAid] 来源视频ID（可选）
  ///
  /// 抛出 [Failure] 当获取失败时
  Future<MemberSpaceEntity> call({
    required int mid,
    String? fromViewAid,
  }) async {
    try {
      if (mid <= 0) {
        throw const ValidationFailure('成员ID必须大于0');
      }

      return await _repository.getMemberSpace(
        mid: mid,
        fromViewAid: fromViewAid,
      );
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
