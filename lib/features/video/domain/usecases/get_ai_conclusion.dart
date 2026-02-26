import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/video/domain/entities/video_ai_conclusion_entity.dart';
import 'package:PiliPlus/features/video/domain/repositories/video_repository.dart';

/// 获取AI总结用例
class GetAIConclusionUseCase {
  final VideoRepository _repository;

  GetAIConclusionUseCase(this._repository);

  /// 执行用例
  ///
  /// [bvid] 视频BV号
  /// [cid] 视频分P的cid
  /// [upMid] UP主mid
  ///
  /// 抛出 [Failure] 当获取失败时
  Future<VideoAIConclusionEntity> call({
    required String bvid,
    required int cid,
    int? upMid,
  }) async {
    try {
      if (bvid.isEmpty) {
        throw const ValidationFailure('bvid不能为空');
      }
      if (cid <= 0) {
        throw const ValidationFailure('cid必须大于0');
      }

      return await _repository.getAIConclusion(
        bvid: bvid,
        cid: cid,
        upMid: upMid,
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
