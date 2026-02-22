import 'package:PiliPlus/features/home_hot/domain/entities/hot_video_result.dart';

/// 热门视频仓库接口
abstract interface class HotVideoRepository {
  /// 获取热门视频列表
  ///
  /// [pn] 页码
  /// [ps] 每页数量
  Future<HotVideoResult> getHotVideos({
    required int pn,
    required int ps,
  });
}
