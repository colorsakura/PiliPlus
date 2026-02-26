import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/models/common/sponsor_block/post_segment_model.dart';
import 'package:PiliPlus/models/common/sponsor_block/segment_type.dart';
import 'package:PiliPlus/features/sponsor_block/data/datasources/sponsor_block_remote_datasource.dart';
import 'package:PiliPlus/features/sponsor_block/domain/entities/sponsor_segment.dart';
import 'package:PiliPlus/features/sponsor_block/domain/entities/sponsor_user_info.dart';
import 'package:PiliPlus/features/sponsor_block/domain/repositories/sponsor_block_repository.dart';

/// SponsorBlock repository implementation
class SponsorBlockRepositoryImpl implements SponsorBlockRepository {
  final SponsorBlockRemoteDataSource remoteDataSource;

  const SponsorBlockRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<SponsorSegmentEntity>> getSkipSegments({
    required String bvid,
    required int cid,
  }) async {
    try {
      final models = await remoteDataSource.getSkipSegments(
        bvid: bvid,
        cid: cid,
      );
      return models.map((model) => SponsorSegmentEntity.fromModel(model)).toList();
    } on Exception {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> voteOnSegment({
    required String uuid,
    int? type,
    SegmentType? category,
  }) async {
    try {
      await remoteDataSource.voteOnSponsorTime(
        uuid: uuid,
        type: type,
        category: category,
      );
    } on Exception {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markSegmentViewed(String uuid) async {
    try {
      await remoteDataSource.viewedVideoSponsorTime(uuid);
    } on Exception {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> checkServiceStatus() async {
    try {
      await remoteDataSource.uptimeStatus();
    } on Exception {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SponsorUserInfoEntity> getUserInfo(
    List<String> query, {
    String? userId,
  }) async {
    try {
      final effectiveUserId = userId ?? '';
      final userInfo = await remoteDataSource.userInfo(
        query,
        userId: effectiveUserId,
      );
      return SponsorUserInfoEntity.fromModel(userInfo, effectiveUserId);
    } on Exception {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<SponsorSegmentEntity>> postSkipSegments({
    required String bvid,
    required int cid,
    required double videoDuration,
    required List<PostSegmentModel> segments,
  }) async {
    try {
      final models = await remoteDataSource.postSkipSegments(
        bvid: bvid,
        cid: cid,
        videoDuration: videoDuration,
        segments: segments,
      );
      return models.map((model) => SponsorSegmentEntity.fromModel(model)).toList();
    } on Exception {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> getPortVideo({
    required String bvid,
    required int cid,
  }) async {
    try {
      return await remoteDataSource.getPortVideo(
        bvid: bvid,
        cid: cid,
      );
    } on Exception {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> postPortVideo({
    required String bvid,
    required int cid,
    required String ytbId,
    required int videoDuration,
  }) async {
    try {
      return await remoteDataSource.postPortVideo(
        bvid: bvid,
        cid: cid,
        ytbId: ytbId,
        videoDuration: videoDuration,
      );
    } on Exception {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
