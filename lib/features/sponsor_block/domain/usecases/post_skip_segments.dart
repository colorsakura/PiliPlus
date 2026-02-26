import 'package:PiliPlus/models/common/sponsor_block/post_segment_model.dart';
import 'package:PiliPlus/features/sponsor_block/domain/entities/sponsor_segment.dart';
import 'package:PiliPlus/features/sponsor_block/domain/repositories/sponsor_block_repository.dart';

/// Post skip segments use case
class PostSkipSegments {
  final SponsorBlockRepository repository;

  const PostSkipSegments(this.repository);

  Future<List<SponsorSegmentEntity>> call({
    required String bvid,
    required int cid,
    required double videoDuration,
    required List<PostSegmentModel> segments,
  }) {
    return repository.postSkipSegments(
      bvid: bvid,
      cid: cid,
      videoDuration: videoDuration,
      segments: segments,
    );
  }
}
