import 'package:PiliPlus/features/video/data/datasources/video_remote_datasource.dart';
import 'package:PiliPlus/features/video/domain/entities/video_ai_conclusion_entity.dart';
import 'package:PiliPlus/features/video/domain/entities/video_detail_entity.dart';
import 'package:PiliPlus/features/video/domain/entities/video_play_info_entity.dart';
import 'package:PiliPlus/features/video/domain/entities/video_play_url_entity.dart';
import 'package:PiliPlus/features/video/domain/entities/video_relation_entity.dart';
import 'package:PiliPlus/features/video/domain/repositories/video_repository.dart';

/// 视频仓库实现
class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource _remoteDataSource;

  VideoRepositoryImpl({
    required VideoRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<VideoDetailEntity> getVideoInfo({
    String? bvid,
    int? aid,
  }) async {
    final data = await _remoteDataSource.videoInfo(
      bvid: bvid,
      aid: aid,
    );
    return VideoDetailEntity.fromMap(data);
  }

  @override
  Future<VideoPlayUrlEntity> getVideoPlayUrl({
    required int cid,
    required int qn,
    int? fnval,
    int? fnver,
    bool? fourk,
    String? bvid,
    int? aid,
    String? session,
  }) async {
    final data = await _remoteDataSource.videoPlayUrl(
      cid: cid,
      qn: qn,
      fnval: fnval,
      fnver: fnver,
      fourk: fourk ?? false,
      bvid: bvid,
      aid: aid,
      session: session,
    );

    // TODO: 根据实际返回的数据结构创建VideoPlayUrlData对象
    return VideoPlayUrlEntity(
      isAvailable: true,
    );
  }

  @override
  Future<void> likeVideo({
    required String bvid,
    required bool like,
  }) async {
    await _remoteDataSource.likeVideo(
      bvid: bvid,
      like: like,
    );
  }

  @override
  Future<void> coinVideo({
    required String bvid,
    required int num,
    bool? selectLike,
  }) async {
    await _remoteDataSource.coinVideo(
      bvid: bvid,
      num: num,
      selectLike: selectLike ?? false,
    );
  }

  @override
  Future<void> favVideo({
    required String bvid,
    required List<int> addMediaIds,
    required List<int> delMediaIds,
  }) async {
    await _remoteDataSource.favVideo(
      bvid: bvid,
      addMediaIds: addMediaIds,
      delMediaIds: delMediaIds,
    );
  }

  @override
  Future<Map<String, dynamic>> ugcTriple({
    required String bvid,
  }) async {
    return await _remoteDataSource.ugcTriple(
      bvid: bvid,
    );
  }

  @override
  Future<VideoRelationEntity> getVideoRelation({
    required String bvid,
  }) async {
    final data = await _remoteDataSource.videoRelation(
      bvid: bvid,
    );
    return VideoRelationEntity.fromMap(data);
  }

  @override
  Future<List<dynamic>> getRelatedVideos({
    required String bvid,
  }) async {
    return await _remoteDataSource.relatedVideos(
      bvid: bvid,
    );
  }

  @override
  Future<void> sendDanmaku({
    required String msg,
    required int oid,
    required int progress,
    required int type,
    int? color,
  }) async {
    await _remoteDataSource.sendDanmaku(
      msg: msg,
      oid: oid,
      progress: progress,
      type: type,
      color: color,
    );
  }

  @override
  Future<VideoAIConclusionEntity> getAIConclusion({
    required String bvid,
    required int cid,
    int? upMid,
  }) async {
    final data = await _remoteDataSource.aiConclusion(
      bvid: bvid,
      cid: cid,
      upMid: upMid,
    );
    return VideoAIConclusionEntity.fromMap(data);
  }

  @override
  Future<VideoPlayInfoEntity> getPlayInfo({
    String? bvid,
    String? aid,
    required int cid,
    int? seasonId,
    int? epId,
  }) async {
    final data = await _remoteDataSource.playInfo(
      aid: aid,
      bvid: bvid,
      cid: cid,
      seasonId: seasonId,
      epId: epId,
    );
    return VideoPlayInfoEntity.fromMap(data);
  }

  @override
  Future<String?> getVTTSubtitles({
    required String subtitleUrl,
  }) async {
    return await _remoteDataSource.vttSubtitles(subtitleUrl);
  }
}
