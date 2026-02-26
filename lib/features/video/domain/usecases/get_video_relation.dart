import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/video/domain/entities/video_relation_entity.dart';
import 'package:PiliPlus/features/video/domain/repositories/video_repository.dart';

/// 获取视频关系用例
class GetVideoRelationUseCase {
  final VideoRepository _repository;

  GetVideoRelationUseCase(this._repository);

  /// 执行用例
  ///
  /// [bvid] 视频BV号
  ///
  /// 抛出 [Failure] 当获取失败时
  Future<VideoRelationEntity> call({
    required String bvid,
  }) async {
    try {
      if (bvid.isEmpty) {
        throw const ValidationFailure('bvid不能为空');
      }

      return await _repository.getVideoRelation(
        bvid: bvid,
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
