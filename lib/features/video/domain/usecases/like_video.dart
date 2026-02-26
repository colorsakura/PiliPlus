import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/video/domain/repositories/video_repository.dart';

/// 点赞视频用例
class LikeVideoUseCase {
  final VideoRepository _repository;

  LikeVideoUseCase(this._repository);

  /// 执行用例
  ///
  /// [bvid] 视频BV号
  /// [like] 是否点赞
  ///
  /// 抛出 [Failure] 当操作失败时
  Future<void> call({
    required String bvid,
    required bool like,
  }) async {
    try {
      if (bvid.isEmpty) {
        throw const ValidationFailure('bvid不能为空');
      }

      await _repository.likeVideo(
        bvid: bvid,
        like: like,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
