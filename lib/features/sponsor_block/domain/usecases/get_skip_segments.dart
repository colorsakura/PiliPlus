import 'package:PiliPlus/features/sponsor_block/domain/entities/sponsor_segment.dart';
import 'package:PiliPlus/features/sponsor_block/domain/repositories/sponsor_block_repository.dart';

/// Get skip segments use case
class GetSkipSegments {
  final SponsorBlockRepository repository;

  const GetSkipSegments(this.repository);

  Future<List<SponsorSegmentEntity>> call({
    required String bvid,
    required int cid,
  }) {
    return repository.getSkipSegments(
      bvid: bvid,
      cid: cid,
    );
  }
}
