import 'package:PiliPlus/features/home_hot/data/datasources/hot_video_remote_datasource.dart';
import 'package:PiliPlus/features/home_hot/domain/entities/hot_video.dart';
import 'package:PiliPlus/features/home_hot/domain/entities/hot_video_result.dart';
import 'package:PiliPlus/features/home_hot/domain/repositories/hot_video_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/model_hot_video_item.dart';

/// 热门视频仓库实现
class HotVideoRepositoryImpl implements HotVideoRepository {
  final HotVideoRemoteDataSource _remoteDataSource;

  HotVideoRepositoryImpl({
    required HotVideoRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<HotVideoResult> getHotVideos({
    required int pn,
    required int ps,
  }) async {
    final result = await _remoteDataSource.fetchHotVideos(
      pn: pn,
      ps: ps,
    );

    return _mapHotVideoResult(result);
  }

  HotVideoResult _mapHotVideoResult(
    LoadingState<List<HotVideoItemModel>> result,
  ) {
    if (result case Success(:final response)) {
      final videos = response
          .map<HotVideo>((item) => HotVideo(video: item))
          .toList();

      return HotVideoResult(
        videos: videos,
        hasMore: videos.isNotEmpty,
        currentPage: 0,
      );
    } else if (result case Error(:final errMsg)) {
      throw Exception(errMsg);
    } else {
      throw Exception('Loading...');
    }
  }
}
