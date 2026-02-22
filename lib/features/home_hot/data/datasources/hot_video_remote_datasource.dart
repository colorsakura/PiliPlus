import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/model_hot_video_item.dart';

/// 热门视频远程数据源
class HotVideoRemoteDataSource {
  /// 从远程获取热门视频列表
  Future<LoadingState<List<HotVideoItemModel>>> fetchHotVideos({
    required int pn,
    required int ps,
  }) {
    return VideoHttp.hotVideoList(
      pn: pn,
      ps: ps,
    );
  }
}
