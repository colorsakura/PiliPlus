import 'package:PiliPlus/models/common/sponsor_block/post_segment_model.dart';
import 'package:PiliPlus/models/common/sponsor_block/segment_type.dart';
import 'package:PiliPlus/features/sponsor_block/domain/entities/sponsor_segment.dart';
import 'package:PiliPlus/features/sponsor_block/domain/entities/sponsor_user_info.dart';

/// SponsorBlock repository interface
abstract class SponsorBlockRepository {
  /// Get skip segments for a video
  Future<List<SponsorSegmentEntity>> getSkipSegments({
    required String bvid,
    required int cid,
  });

  /// Vote on a segment
  Future<void> voteOnSegment({
    required String uuid,
    int? type,
    SegmentType? category,
  });

  /// Mark segment as viewed
  Future<void> markSegmentViewed(String uuid);

  /// Check service status
  Future<void> checkServiceStatus();

  /// Get user information
  Future<SponsorUserInfoEntity> getUserInfo(
    List<String> query, {
    String? userId,
  });

  /// Post skip segments
  Future<List<SponsorSegmentEntity>> postSkipSegments({
    required String bvid,
    required int cid,
    required double videoDuration,
    required List<PostSegmentModel> segments,
  });

  /// Get port video info
  Future<String> getPortVideo({
    required String bvid,
    required int cid,
  });

  /// Post port video binding
  Future<String> postPortVideo({
    required String bvid,
    required int cid,
    required String ytbId,
    required int videoDuration,
  });
}
