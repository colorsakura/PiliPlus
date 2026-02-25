/// 视频HTTP适配器
///
/// 临时适配器层，用于逐步迁移到干净架构
/// TODO: 迁移完成后移除此文件，所有调用改为使用 Repository
library;

import 'package:PiliPlus/features/video/data/datasources/video_remote_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/home/rcmd/result.dart';
import 'package:PiliPlus/models/model_hot_video_item.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/models/pgc/pgc_rank/pgc_rank_item_model.dart';
import 'package:PiliPlus/models/popular/popular_series_list/list.dart';
import 'package:PiliPlus/models/popular/popular_series_one/data.dart';
import 'package:PiliPlus/models/popular/popular_precious/data.dart';
import 'package:PiliPlus/models/triple/pgc_triple.dart';
import 'package:PiliPlus/models/triple/ugc_triple.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:PiliPlus/models/video/video_relation/data.dart';
import 'package:PiliPlus/models/video/video_ai_conclusion/data.dart';
import 'package:PiliPlus/models/video/video_detail/data.dart';
import 'package:PiliPlus/models/video/video_note_list/data.dart';
import 'package:PiliPlus/models/video/video_play_info/data.dart';
import 'package:PiliPlus/utils/recommend_filter.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/global_data.dart';

/// 视频HTTP适配器
///
/// 保留旧的API接口，内部调用新的数据源
abstract final class VideoHttp {
  static final VideoRemoteDataSource _dataSource = VideoRemoteDataSource();

  static RegExp zoneRegExp = RegExp(Pref.banWordForZone, caseSensitive: false);
  static bool enableFilter = zoneRegExp.pattern.isNotEmpty;

  /// 首页推荐视频
  static Future<LoadingState<List<RecVideoItemModel>>> rcmdVideoList({
    required int ps,
    required int freshIdx,
  }) async {
    try {
      final data = await _dataSource.rcmdVideoList(
        ps: ps,
        freshIdx: freshIdx,
      );

      List<RecVideoItemModel> list = [];
      for (final i in data['item']) {
        if (i['goto'] == 'av' &&
            (i['owner'] != null &&
                !GlobalData().blackMids.contains(i['owner']['mid']))) {
          RecVideoItemModel videoItem = RecVideoItemModel.fromJson(i);
          if (!RecommendFilter.filter(videoItem)) {
            if (!enableFilter ||
                (i['tname'] == null || !zoneRegExp.hasMatch(i['tname']))) {
              list.add(videoItem);
            }
          }
        }
      }
      return Success(list);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 视频详情
  static Future<LoadingState<VideoDetailData>> videoInfo({
    String? bvid,
    int? aid,
  }) async {
    try {
      final data = await _dataSource.videoInfo(bvid: bvid, aid: aid);
      return Success(VideoDetailData.fromJson(data));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 视频播放URL
  static Future<LoadingState<PlayUrlModel>> videoPlayUrl({
    required int cid,
    required int qn,
    int? fnval,
    int? fnver,
    bool fourk = false,
    String? bvid,
    int? aid,
  }) async {
    try {
      final data = await _dataSource.videoPlayUrl(
        cid: cid,
        qn: qn,
        fnval: fnval,
        fnver: fnver,
        fourk: fourk,
        bvid: bvid,
        aid: aid,
      );
      return Success(PlayUrlModel.fromJson(data));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 点赞视频
  static Future<LoadingState<void>> likeVideo({
    required String bvid,
    required bool like,
  }) async {
    try {
      await _dataSource.likeVideo(bvid: bvid, like: like);
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 投币视频
  static Future<LoadingState<void>> coinVideo({
    required String bvid,
    required int num,
    bool selectLike = false,
  }) async {
    try {
      await _dataSource.coinVideo(
        bvid: bvid,
        num: num,
        selectLike: selectLike,
      );
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 收藏视频
  static Future<LoadingState<void>> favVideo({
    required String bvid,
    required List<int> addMediaIds,
    required List<int> delMediaIds,
  }) async {
    try {
      await _dataSource.favVideo(
        bvid: bvid,
        addMediaIds: addMediaIds,
        delMediaIds: delMediaIds,
      );
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 一键三连
  static Future<LoadingState<UgcTripleData>> ugcTriple({
    required String bvid,
  }) async {
    try {
      final data = await _dataSource.ugcTriple(bvid: bvid);
      return Success(UgcTripleData.fromJson(data));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 视频关系
  static Future<LoadingState<VideoRelationData>> videoRelation({
    required String bvid,
  }) async {
    try {
      final data = await _dataSource.videoRelation(bvid: bvid);
      return Success(VideoRelationData.fromJson(data));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 相关视频
  static Future<LoadingState<List<dynamic>>> relatedVideos({
    required String bvid,
  }) async {
    try {
      final data = await _dataSource.relatedVideos(bvid: bvid);
      return Success(data);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 发送弹幕
  static Future<LoadingState<void>> sendDanmaku({
    required String msg,
    required int oid,
    required int progress,
    required int type,
    int? color,
  }) async {
    try {
      await _dataSource.sendDanmaku(
        msg: msg,
        oid: oid,
        progress: progress,
        type: type,
        color: color,
      );
      return const Success(null);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// AI总结
  static Future<LoadingState<AiConclusionData>> aiConclusion({
    required String bvid,
    required int cid,
    int? upMid,
  }) async {
    try {
      final data = await _dataSource.aiConclusion(
        bvid: bvid,
        cid: cid,
        upMid: upMid,
      );
      return Success(AiConclusionData.fromJson(data));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 播放信息
  static Future<LoadingState<PlayInfoData>> playInfo({
    String? aid,
    String? bvid,
    required int cid,
    int? seasonId,
    int? epId,
  }) async {
    try {
      final data = await _dataSource.playInfo(
        aid: aid,
        bvid: bvid,
        cid: cid,
        seasonId: seasonId,
        epId: epId,
      );
      return Success(PlayInfoData.fromJson(data));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 视频排行榜
  static Future<LoadingState<List<HotVideoItemModel>>> getRankVideoList(
    int rid,
  ) async {
    try {
      final list = await _dataSource.getRankVideoList(rid);

      List<HotVideoItemModel> result = [];
      for (final i in list) {
        if (!GlobalData().blackMids.contains(i['owner']['mid']) &&
            !RecommendFilter.filterTitle(i['title']) &&
            !RecommendFilter.filterLikeRatio(
              i['stat']['like'],
              i['stat']['view'],
            )) {
          if (!enableFilter ||
              (i['tname'] == null || !zoneRegExp.hasMatch(i['tname']))) {
            result.add(HotVideoItemModel.fromJson(i));
          }
        }
      }
      return Success(result);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// PGC排行
  static Future<LoadingState<List<PgcRankItemModel>?>> pgcRankList({
    int day = 3,
    required int seasonType,
  }) async {
    try {
      final data = await _dataSource.pgcRankList(
        day: day,
        seasonType: seasonType,
      );
      return Success(
        data?.map((e) => PgcRankItemModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 视频笔记列表
  static Future<LoadingState<VideoNoteData>> getVideoNoteList({
    dynamic oid,
    dynamic uperMid,
    required int page,
  }) async {
    try {
      final data = await _dataSource.getVideoNoteList(
        oid: oid,
        uperMid: uperMid,
        page: page,
      );
      return Success(VideoNoteData.fromJson(data));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 热门合集列表
  static Future<LoadingState<List<PopularSeriesListItem>?>> popularSeriesList() async {
    try {
      final data = await _dataSource.popularSeriesList();
      return Success(
        data?.map((e) => PopularSeriesListItem.fromJson(e)).toList(),
      );
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 热门合集详情
  static Future<LoadingState<PopularSeriesOneData>> popularSeriesOne({
    required int number,
  }) async {
    try {
      final data = await _dataSource.popularSeriesOne(number: number);
      return Success(PopularSeriesOneData.fromJson(data));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 热门视频
  static Future<LoadingState<PopularPreciousData>> popularPrecious({
    required int page,
  }) async {
    try {
      final data = await _dataSource.popularPrecious(page: page);
      return Success(PopularPreciousData.fromJson(data));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 电视播放URL
  static Future<LoadingState<PlayUrlModel>> tvPlayUrl({
    required int cid,
    required int objectId,
    required int playurlType,
    int? qn,
  }) async {
    try {
      final data = await _dataSource.tvPlayUrl(
        cid: cid,
        objectId: objectId,
        playurlType: playurlType,
        qn: qn,
      );
      return Success(PlayUrlModel.fromJson(data));
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// 获取VTT字幕
  static Future<String?> vttSubtitles(String subtitleUrl) async {
    try {
      return await _dataSource.vttSubtitles(subtitleUrl);
    } catch (e) {
      return null;
    }
  }
}
