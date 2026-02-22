import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/home/rcmd/result.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';

/// 视频推荐远程数据源
class VideoRecommendationRemoteDataSource {
  /// 从Web API获取推荐视频
  Future<LoadingState<List<RecVideoItemModel>>> fetchWebRecommendations({
    required int freshIdx,
    int ps = 20,
  }) {
    return VideoHttp.rcmdVideoList(
      freshIdx: freshIdx,
      ps: ps,
    );
  }

  /// 从App API获取推荐视频
  Future<LoadingState<List<RecVideoItemAppModel>>> fetchAppRecommendations({
    required int freshIdx,
  }) {
    return VideoHttp.rcmdVideoListApp(
      freshIdx: freshIdx,
    );
  }
}
