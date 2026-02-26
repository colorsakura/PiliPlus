import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/video/domain/entities/video_play_url_entity.dart';
import 'package:PiliPlus/features/video/domain/repositories/video_repository.dart';

/// 获取视频播放URL用例
class GetVideoPlayUrlUseCase {
  final VideoRepository _repository;

  GetVideoPlayUrlUseCase(this._repository);

  /// 执行用例
  ///
  /// [cid] 视频分P的cid
  /// [qn] 视频质量
  /// [bvid] 视频BV号
  /// [aid] 视频AV号
  /// [session] 会话ID
  ///
  /// 抛出 [Failure] 当获取失败时
  Future<VideoPlayUrlEntity> call({
    required int cid,
    required int qn,
    int? fnval,
    int? fnver,
    bool? fourk,
    String? bvid,
    int? aid,
    String? session,
  }) async {
    try {
      if (cid <= 0) {
        throw const ValidationFailure('cid必须大于0');
      }

      return await _repository.getVideoPlayUrl(
        cid: cid,
        qn: qn,
        fnval: fnval,
        fnver: fnver,
        fourk: fourk,
        bvid: bvid,
        aid: aid,
        session: session,
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
