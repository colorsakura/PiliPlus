import 'package:PiliPlus/features/home_hot/domain/entities/hot_video_result.dart';
import 'package:PiliPlus/features/home_hot/domain/repositories/hot_video_repository.dart';

/// 获取热门视频用例
class FetchHotVideosUseCase {
  final HotVideoRepository _repository;

  const FetchHotVideosUseCase(this._repository);

  /// 执行用例：获取热门视频
  ///
  /// [pn] 页码
  /// [ps] 每页数量
  Future<HotVideoResult> call({
    required int pn,
    required int ps,
  }) {
    return _repository.getHotVideos(
      pn: pn,
      ps: ps,
    );
  }
}
