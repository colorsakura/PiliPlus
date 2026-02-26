import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/video/domain/entities/video_detail_entity.dart';
import 'package:PiliPlus/features/video/domain/repositories/video_repository.dart';

/// 获取视频详情用例
class GetVideoDetailUseCase {
  final VideoRepository _repository;

  GetVideoDetailUseCase(this._repository);

  /// 执行用例
  ///
  /// [bvid] 视频BV号
  /// [aid] 视频AV号
  ///
  /// 抛出 [Failure] 当获取失败时
  Future<VideoDetailEntity> call({
    String? bvid,
    int? aid,
  }) async {
    try {
      if (bvid == null && aid == null) {
        throw const ValidationFailure('bvid或aid必须提供其中一个');
      }

      return await _repository.getVideoInfo(
        bvid: bvid,
        aid: aid,
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
